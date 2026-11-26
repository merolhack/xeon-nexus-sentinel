#!/usr/bin/env python3
"""
diagnose-server.py — Monitor Unificado de Arranque y Telemetría Headless
Diseñado para el HP ProLiant ML150 G6 en base a la matriz de diagnóstico de Gemini Notebook.
Monitorea capa de enlace físico (L2/PHY), tráfico PXE/iPXE y disponibilidad de SSH/Cockpit.
"""

import sys
import time
import socket
import subprocess
import concurrent.futures
import argparse

SERVER_MAC = "44:1e:a1:6e:d2:e4"
SUBNET_PREFIX = "192.168.137."
TIMEOUT_TCP = 0.25  # Timeout estricto anti-bloqueo (Mandato 6)

def get_net_adapter_status():
    """Consulta velocidad de enlace y estado del adaptador Ethernet en Windows."""
    try:
        cmd = ["powershell.exe", "-NoProfile", "-Command", 
               "Get-NetAdapter -Name 'Ethernet' -ErrorAction SilentlyContinue | Select-Object -Property Status, LinkSpeed | ConvertTo-Json"]
        res = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
        if res.returncode == 0 and res.stdout.strip():
            import json
            data = json.loads(res.stdout)
            return data.get("Status", "Unknown"), data.get("LinkSpeed", "Unknown")
    except Exception:
        pass
    return "Unknown", "Unknown"

def check_tcp_port(ip, port):
    """Verifica si un puerto TCP específico está abierto con timeout ultra corto."""
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(TIMEOUT_TCP)
        res = s.connect_ex((ip, port))
        s.close()
        return res == 0
    except Exception:
        return False

def scan_subnet_services():
    """Escanea concurrentemente los puertos 22 (SSH) y 9090 (Cockpit) en la subred 192.168.137.x."""
    active_services = []
    ips = [f"{SUBNET_PREFIX}{i}" for i in range(2, 255)]

    def probe(ip):
        ssh_open = check_tcp_port(ip, 22)
        cockpit_open = check_tcp_port(ip, 9090)
        if ssh_open or cockpit_open:
            return {
                "ip": ip,
                "ssh": ssh_open,
                "cockpit": cockpit_open
            }
        return None

    with concurrent.futures.ThreadPoolExecutor(max_workers=64) as executor:
        results = executor.map(probe, ips)
        for r in results:
            if r:
                active_services.append(r)

    return active_services

def check_recent_pxe_events():
    """Inspecciona los logs recientes del servidor PXE en segundo plano."""
    log_path = r"C:\Users\lenin\.gemini\antigravity\brain\26b24acc-51b2-4ef2-a316-8341d9778692\.system_generated\tasks\task-477.log"
    events = []
    try:
        with open(log_path, "r", encoding="utf-8", errors="ignore") as f:
            lines = f.readlines()[-25:]
            for line in lines:
                if SERVER_MAC in line or "boot.ipxe" in line or "undionly.kpxe" in line:
                    events.append(line.strip())
    except Exception:
        pass
    return events

def diagnose():
    status, speed = get_net_adapter_status()
    pxe_events = check_recent_pxe_events()
    services = scan_subnet_services()

    # Deducción del estado según matriz de Gemini Notebook
    phase = "DESCONOCIDO"
    icon = "⚪"
    detail = ""

    if status != "Up":
        phase = "APAGADO O DESCONECTADO"
        icon = "🔴"
        detail = "El cable Ethernet no tiene enlace físico. Verifica conexión en el puerto INFERIOR del servidor."
    elif services:
        phase = "SISTEMA OPERATIVO LISTO (ALMALINUX 9)"
        icon = "🟢"
        ssh_ips = [s['ip'] for s in services if s['ssh']]
        detail = f"¡Servicios activos detectados! IPs con SSH abierto: {', '.join(ssh_ips)}"
    elif "1 Gbps" in speed:
        phase = "KERNEL LINUX ACTIVO (INICIALIZANDO SERVICIOS)"
        icon = "🟣"
        detail = "El enlace físico negoció 1 Gbps (driver tg3 activo). El sistema está cargando NetworkManager y OpenSSH."
    elif pxe_events:
        phase = "ARRANQUE POR RED EN PROCESO (PXE / iPXE)"
        icon = "🔵"
        detail = f"Último evento PXE: {pxe_events[-1]}"
    elif "100 Mbps" in speed:
        phase = "POST DE BIOS / PAUSA DE HARDWARE"
        icon = "🟡"
        detail = "Enlace en 100 Mbps. El servidor está en BIOS Setup, esperando F1 por advertencia o en el menú BBS (ESC)."

    print("\n" + "=" * 70)
    print("  XEON NEXUS SENTINEL — MONITOR DE ESTADO HEADLESS (HP ML150 G6)")
    print("=" * 70)
    print(f"  Enlace Físico Ethernet : {status} a {speed}")
    print(f"  Fase Diagnosticada     : {icon} {phase}")
    print(f"  Detalle Operativo      : {detail}")
    
    if services:
        print("\n  [ACCESO REMOTO DISPONIBLE]:")
        for s in services:
            if s["ssh"]:
                print(f"   👉 SSH     : ssh root@{s['ip']}  (clave: nexusadmin2026!)")
            if s["cockpit"]:
                print(f"   👉 Cockpit : https://{s['ip']}:9090")
    else:
        print("\n  [PUERTOS SSH/COCKPIT]: Ningún servicio respondiendo aún en 192.168.137.x")

    if pxe_events:
        print(f"\n  [TRAFICO PXE DETECTADO (Últimos {len(pxe_events)} eventos)]:")
        for ev in pxe_events[-3:]:
            print(f"   • {ev}")

    print("=" * 70 + "\n")
    return bool(services)

def main():
    parser = argparse.ArgumentParser(description="Monitor de Telemetría Headless para Servidor HP")
    parser.add_argument("--watch", action="store_true", help="Monitorea en bucle continuo cada 3 segundos hasta que SSH esté listo")
    args = parser.parse_args()

    if args.watch:
        print("Iniciando monitoreo continuo (Presiona Ctrl+C para detener)...")
        while True:
            ready = diagnose()
            if ready:
                print("🎯 ¡Servidor listo y accesible por SSH! Finalizando monitor.")
                break
            time.sleep(3)
    else:
        diagnose()

if __name__ == "__main__":
    main()
