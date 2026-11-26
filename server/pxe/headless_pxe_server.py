#!/usr/bin/env python3
"""
Headless PXE / TFTP / HTTP Server para instalacion desatendida de AlmaLinux 9 en HP ProLiant ML150 G6.
Completamente autonomo, en Python puro estandar (sin dependencias externas).

Caracteristicas:
1. TFTP Server (UDP 69): Entrega undionly.kpxe (iPXE) al cliente BIOS en milisegundos.
2. HTTP Server (TCP 8080): Entrega boot.ipxe, ks.cfg, vmlinuz e initrd.img a velocidad Gigabit.
3. DHCP / ProxyDHCP Server (UDP 67 / 4011):
   - Si la peticion es de BIOS PXE standard: ofrece next-server=192.168.137.1 y bootfile=undionly.kpxe.
   - Si la peticion proviene de iPXE (detecta Option 175 / User-Class iPXE): ofrece bootfile=http://192.168.137.1:8080/boot.ipxe.
   - Evita permanentemente el bucle infinito de iPXE sin intervencion humana (100% Headless).
"""

import os
import sys
import socket
import struct
import threading
import time
from http.server import HTTPServer, SimpleHTTPRequestHandler

TFTP_DIR = r"C:\Users\lenin\pxeboot\tftp"
WWW_DIR = r"C:\Users\lenin\pxeboot\www"
SERVER_IP = "192.168.137.1"
HTTP_PORT = 8000
SUBNET_MASK = "255.255.255.0"
IP_POOL_START = "192.168.137.50"


def ip_to_bytes(ip_str):
    return socket.inet_aton(ip_str)


# =====================================================================
# 1. TFTP SERVER (RFC 1350 + RFC 2348 blksize support)
# =====================================================================
class TFTPServer:
    def __init__(self, server_ip=SERVER_IP, port=69, root_dir=TFTP_DIR):
        self.server_ip = server_ip
        self.port = port
        self.root_dir = root_dir
        self.sockets = []
        for host in [server_ip, "0.0.0.0"]:
            try:
                s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
                s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                s.bind((host, port))
                self.sockets.append((s, host))
            except Exception:
                pass
        self.running = False

    def start(self):
        self.running = True
        print(f"[TFTP] Servidor escuchando en {len(self.sockets)} endpoints (puerto {self.port}) (Directorio: {self.root_dir})")
        threads = []
        for s, host in self.sockets:
            t = threading.Thread(target=self.listen_socket, args=(s, host), daemon=True)
            t.start()
            threads.append(t)
        for t in threads:
            t.join()

    def listen_socket(self, s, host):
        while self.running:
            try:
                data, addr = s.recvfrom(2048)
                threading.Thread(target=self.handle_client, args=(data, addr, s), daemon=True).start()
            except Exception as e:
                if self.running:
                    print(f"[TFTP] Error en socket {host}: {e}")
                break

    def handle_client(self, data, addr, in_sock=None):
        if len(data) < 4:
            return
        opcode = struct.unpack("!H", data[:2])[0]
        if opcode != 1:  # 1 = RRQ (Read Request)
            return

        # Parse filename and mode
        parts = data[2:].split(b"\x00")
        filename = parts[0].decode("ascii", errors="ignore").lstrip("/\\")
        mode = parts[1].decode("ascii", errors="ignore") if len(parts) > 1 else "octet"
        
        # Parse options (blksize)
        blksize = 512
        options = {}
        if len(parts) > 2:
            i = 2
            while i < len(parts) - 1:
                opt_name = parts[i].decode("ascii", errors="ignore").lower()
                opt_val = parts[i+1].decode("ascii", errors="ignore")
                options[opt_name] = opt_val
                i += 2
            if "blksize" in options:
                try:
                    blksize = int(options["blksize"])
                    blksize = min(max(blksize, 512), 1468)
                except ValueError:
                    blksize = 512

        filepath = os.path.join(self.root_dir, os.path.basename(filename))
        if not os.path.exists(filepath):
            # Error response: File not found (error code 1)
            err_msg = b"\x00\x05\x00\x01File not found\x00"
            if in_sock:
                in_sock.sendto(err_msg, addr)
            print(f"[TFTP] Solicitud de {addr[0]}: archivo no encontrado '{filename}'")
            return

        print(f"[TFTP] Enviando '{filename}' ({os.path.getsize(filepath)} bytes, blksize={blksize}) a {addr[0]}")
        with open(filepath, "rb") as f:
            file_data = f.read()

        client_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        try:
            client_sock.bind((self.server_ip, 0))
        except Exception:
            pass
        client_sock.settimeout(5.0)

        block_num = 1
        offset = 0

        # Si el cliente pidio blksize, responder con OACK (Opcode 6)
        if "blksize" in options:
            oack = b"\x00\x06blksize\x00" + str(blksize).encode("ascii") + b"\x00"
            try:
                client_sock.sendto(oack, addr)
                ack, client_addr = client_sock.recvfrom(512)
            except socket.timeout:
                client_sock.close()
                return

        # Enviar bloques de datos
        while offset < len(file_data) or block_num == 1:
            chunk = file_data[offset:offset + blksize]
            data_pkt = struct.pack("!HH", 3, block_num) + chunk
            
            for retries in range(3):
                client_sock.sendto(data_pkt, addr)
                try:
                    ack_pkt, _ = client_sock.recvfrom(512)
                    if len(ack_pkt) >= 4:
                        ack_op, ack_block = struct.unpack("!HH", ack_pkt[:4])
                        if ack_op == 4 and ack_block == block_num:
                            break
                except socket.timeout:
                    continue
            else:
                print(f"[TFTP] Timeout enviando bloque {block_num} a {addr[0]}")
                break

            offset += len(chunk)
            block_num = (block_num + 1) & 0xFFFF
            if len(chunk) < blksize:
                # Ultimo bloque enviado
                break

        client_sock.close()
        print(f"[TFTP] Transferencia de '{filename}' completada con exito para {addr[0]}")

    def stop(self):
        self.running = False
        self.sock.close()


# =====================================================================
# 2. HTTP SERVER (RFC 7230)
# =====================================================================
import functools

class QuickHTTPServer(HTTPServer):
    def server_bind(self):
        self.server_name = SERVER_IP
        self.server_port = self.server_address[1]
        self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.socket.bind(self.server_address)

def start_http_server():
    try:
        handler = functools.partial(SimpleHTTPRequestHandler, directory=WWW_DIR)
        server = QuickHTTPServer(("0.0.0.0", HTTP_PORT), handler)
        print(f"[HTTP] Servidor web escuchando en http://0.0.0.0:{HTTP_PORT} (Directorio: {WWW_DIR})", flush=True)
        server.serve_forever()
    except Exception as e:
        print(f"[HTTP] ERROR: {e}", flush=True)


# =====================================================================
# 3. DHCP / PROXY-DHCP SERVER (RFC 2131 + RFC 4578 PXE)
# =====================================================================
class DHCPServer:
    def __init__(self, server_ip=SERVER_IP, assigned_ip=IP_POOL_START):
        self.server_ip = server_ip
        self.assigned_ip = assigned_ip
        self.sockets = []
        # Escuchar tanto en puerto 67 (DHCP estandar) como en 4011 (ProxyDHCP para PXE)
        for ip in [server_ip, "0.0.0.0"]:
            for port in [67, 4011]:
                try:
                    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
                    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                    s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
                    s.bind((ip, port))
                    self.sockets.append((s, ip, port))
                except Exception as e:
                    pass

    def start(self):
        print(f"[DHCP] Servidor DHCP/ProxyDHCP escuchando en {len(self.sockets)} endpoints (67 y 4011)", flush=True)
        threads = []
        for s, ip, port in self.sockets:
            t = threading.Thread(target=self.listen_socket, args=(s, ip, port), daemon=True)
            t.start()
            threads.append(t)
        for t in threads:
            t.join()

    def listen_socket(self, sock, ip, port):
        print(f"[DHCP] Escuchando activamente en {ip}:{port}", flush=True)
        while True:
            try:
                data, addr = sock.recvfrom(4096)
                threading.Thread(target=self.handle_dhcp, args=(data, addr, sock), daemon=True).start()
            except Exception as e:
                break

    def handle_dhcp(self, data, addr, sock):
        if len(data) < 240:
            return
        op, htype, hlen, hops, xid = struct.unpack("!BBBBI", data[:8])
        if op != 1:  # Solo solicitudes BOOTREQUEST
            return

        chaddr = data[28:44]
        mac_str = ":".join(f"{b:02x}" for b in chaddr[:hlen])
        cookie = data[236:240]
        if cookie != b"\x63\x82\x53\x63":
            return

        # Parsear opciones DHCP
        options = {}
        idx = 240
        while idx < len(data):
            opt_code = data[idx]
            if opt_code == 255:  # End
                break
            if opt_code == 0:  # Pad
                idx += 1
                continue
            if idx + 1 >= len(data):
                break
            opt_len = data[idx + 1]
            opt_val = data[idx + 2:idx + 2 + opt_len]
            options[opt_code] = opt_val
            idx += 2 + opt_len

        msg_type = options.get(53, b"\x00")[0]
        is_ipxe = (175 in options) or (77 in options and b"iPXE" in options[77])

        # Determinar archivo de arranque
        if is_ipxe:
            boot_file = f"http://{self.server_ip}:{HTTP_PORT}/boot.ipxe".encode("ascii")
            client_type = "iPXE Client"
        else:
            boot_file = b"undionly.kpxe"
            client_type = "BIOS PXE ROM"

        if msg_type == 1:  # DHCP DISCOVER
            print(f"[DHCP] DISCOVER recibido de MAC {mac_str} ({client_type}) en puerto {sock.getsockname()[1]}")
            self.send_offer(xid, chaddr, boot_file, addr, is_ipxe, sock)
        elif msg_type == 3:  # DHCP REQUEST
            print(f"[DHCP] REQUEST recibido de MAC {mac_str} ({client_type}) en puerto {sock.getsockname()[1]}")
            self.send_ack(xid, chaddr, boot_file, addr, is_ipxe, sock)

    def send_offer(self, xid, chaddr, boot_file, addr, is_ipxe, sock):
        # Construir DHCPOFFER
        yiaddr = ip_to_bytes(self.assigned_ip)
        siaddr = ip_to_bytes(self.server_ip)
        
        # Header (236 bytes)
        hdr = struct.pack("!BBBBIHH4s4s4s4s16s64s128s",
                          2, 1, 6, 0, xid, 0, 0x8000,
                          b"\x00\x00\x00\x00",
                          yiaddr,
                          siaddr,
                          b"\x00\x00\x00\x00",
                          chaddr,
                          self.server_ip.encode("ascii")[:64].ljust(64, b"\x00"),
                          boot_file[:128].ljust(128, b"\x00"))
        
        cookie = b"\x63\x82\x53\x63"
        opts = bytearray()
        opts += b"\x35\x01\x02"  # Option 53: DHCP Offer (len 1, val 2)
        opts += b"\x36\x04" + siaddr  # Option 54: Server ID
        opts += b"\x01\x04" + ip_to_bytes(SUBNET_MASK)  # Option 1: Subnet mask
        opts += b"\x03\x04" + siaddr  # Option 3: Router
        opts += b"\x06\x04" + siaddr  # Option 6: DNS
        opts += b"\x33\x04\x00\x00\x0e\x10"  # Option 51: Lease time (3600s)
        
        # Option 66: TFTP Server name
        server_name_bytes = self.server_ip.encode("ascii")
        opts += b"\x42" + bytes([len(server_name_bytes)]) + server_name_bytes
        
        # Option 67: Bootfile name
        opts += b"\x43" + bytes([len(boot_file)]) + boot_file

        # En un servidor DHCP integrado (no proxy separado), la Option 60 NO debe
        # enviarse en el puerto 67 porque hace que la ROM PXE descarte el bootfile
        # esperando un proxy DHCP externo. Solo se envia si es puerto 4011.
        if sock.getsockname()[1] == 4011 and not is_ipxe:
            pxe_client = b"PXEClient"
            opts += b"\x3c" + bytes([len(pxe_client)]) + pxe_client

        opts += b"\xff"  # End

        pkt = hdr + cookie + bytes(opts)
        if sock.getsockname()[1] == 4011:
            sock.sendto(pkt, (addr[0], addr[1]))
            try:
                sock.sendto(pkt, (addr[0], 68))
            except Exception:
                pass
            print(f"[DHCP-4011] Enviado DHCPOFFER -> {addr[0]}:{addr[1]} (Bootfile: {boot_file.decode('ascii')})")
        else:
            # Enviar por subnet broadcast de Ethernet Y broadcast universal
            for broadcast_ip in ["192.168.137.255", "255.255.255.255"]:
                try:
                    sock.sendto(pkt, (broadcast_ip, 68))
                except Exception:
                    pass
            print(f"[DHCP-67] Enviado DHCPOFFER -> 192.168.137.255:68 / 255.255.255.255:68 (Bootfile: {boot_file.decode('ascii')})")

    def send_ack(self, xid, chaddr, boot_file, addr, is_ipxe, sock):
        yiaddr = ip_to_bytes(self.assigned_ip)
        siaddr = ip_to_bytes(self.server_ip)

        hdr = struct.pack("!BBBBIHH4s4s4s4s16s64s128s",
                          2, 1, 6, 0, xid, 0, 0x8000,
                          b"\x00\x00\x00\x00",
                          yiaddr,
                          siaddr,
                          b"\x00\x00\x00\x00",
                          chaddr,
                          self.server_ip.encode("ascii")[:64].ljust(64, b"\x00"),
                          boot_file[:128].ljust(128, b"\x00"))

        cookie = b"\x63\x82\x53\x63"
        opts = bytearray()
        opts += b"\x35\x01\x05"  # Option 53: DHCP ACK (len 1, val 5)
        opts += b"\x36\x04" + siaddr
        opts += b"\x01\x04" + ip_to_bytes(SUBNET_MASK)
        opts += b"\x03\x04" + siaddr
        opts += b"\x06\x04" + siaddr
        opts += b"\x33\x04\x00\x00\x0e\x10"

        server_name_bytes = self.server_ip.encode("ascii")
        opts += b"\x42" + bytes([len(server_name_bytes)]) + server_name_bytes
        opts += b"\x43" + bytes([len(boot_file)]) + boot_file

        if sock.getsockname()[1] == 4011 and not is_ipxe:
            pxe_client = b"PXEClient"
            opts += b"\x3c" + bytes([len(pxe_client)]) + pxe_client

        opts += b"\xff"

        pkt = hdr + cookie + bytes(opts)
        if sock.getsockname()[1] == 4011:
            sock.sendto(pkt, (addr[0], addr[1]))
            try:
                sock.sendto(pkt, (addr[0], 68))
            except Exception:
                pass
            print(f"[DHCP-4011] Enviado DHCPACK -> {addr[0]}:{addr[1]} (Bootfile: {boot_file.decode('ascii')})")
        else:
            for broadcast_ip in ["192.168.137.255", "255.255.255.255"]:
                try:
                    sock.sendto(pkt, (broadcast_ip, 68))
                except Exception:
                    pass
            print(f"[DHCP-67] Enviado DHCPACK -> 192.168.137.255:68 / 255.255.255.255:68 (Bootfile: {boot_file.decode('ascii')})")


# =====================================================================
# MAIN RUNNER
# =====================================================================
if __name__ == "__main__":
    print("=" * 65)
    print("   XEON NEXUS SENTINEL - SERVIDOR PXE/TFTP/HTTP AUTONOMO")
    print("   Instalacion Headless 100% Desatendida de AlmaLinux 9")
    print("=" * 65)
    print(f"IP Servidor Laptop:  {SERVER_IP}")
    print(f"Directorio TFTP:     {TFTP_DIR}")
    print(f"Directorio HTTP:     {WWW_DIR}")
    print("-" * 65)

    # Iniciar HTTP Server en hilo secundario
    http_thread = threading.Thread(target=start_http_server, daemon=True)
    http_thread.start()

    # Iniciar TFTP Server en hilo secundario
    tftp_server = TFTPServer()
    tftp_thread = threading.Thread(target=tftp_server.start, daemon=True)
    tftp_thread.start()

    # Iniciar DHCP Server en hilo principal
    try:
        dhcp_server = DHCPServer()
        dhcp_server.start()
    except KeyboardInterrupt:
        print("\n[INFO] Servidor detenido por el usuario.")
        sys.exit(0)
