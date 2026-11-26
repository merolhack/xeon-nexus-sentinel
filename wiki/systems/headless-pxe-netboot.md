---
title: "Arquitectura de Despliegue Headless PXE Netboot para HP ProLiant ML150 G6"
description: "Servidor PXE/TFTP/HTTP autonomo en Python para instalacion desatendida de AlmaLinux 9 en servidores sin monitor ni teclado."
category: "systems"
date: "2026-11-23"
status: "active"
tags: ["pxe", "netboot", "tftp", "http", "ipxe", "kickstart", "almalinux9", "headless"]
---

# Arquitectura de Despliegue Headless PXE Netboot

## 1. Contexto y Desafio Tecnico
El servidor **HP ProLiant ML150 G6** es un nodo de computo empresarial:
- Controlador de almacenamiento interno: HP Smart Array P410 / SAS-SATA con discos configurados.
- Sistema operativo preexistente en disco: **Windows Server 2008 R2 Enterprise**.
- Prioridad de arranque del BIOS: Da preferencia al disco duro interno sobre el arranque por red PXE.
- Sin monitor ni teclado USB externo conectado directamente al servidor (pantalla verificada por HDMI en TV mediante conversor VGA a HDMI con alimentacion USB).
- Medios disponibles en laptop: Grabadora externa USB **PHILIPS CDRW/DVD SCB5265 (Unidad E:)** y discos virgenes **CD-R (700 MB)**.

## 2. Estrategia de Arranque Hibrido: CD-R iPXE + Red Gigabit (PXE/HTTP)
Dado que la imagen oficial `AlmaLinux-9-boot.iso` pesa 1.55 GB y excede la capacidad fisica de un CD-R (700 MB maximo, requiere DVD):
1. Se emplea **iPXE ISO (`ipxe.iso`, ~9 MB)** grabada en el CD-R.
2. El BIOS del HP ProLiant ML150 G6 prioriza de fabrica la unidad lectora frontal DVD/CD sobre los discos duros internos.
3. El CD-R arranca iPXE en menos de 2 segundos sin requerir intervencion de teclado.
4. iPXE se comunica por el puerto inferior Gigabit (`1/Mgmt`) con el servidor autonomo en la laptop (`192.168.137.1:8000`).
5. Descarga `vmlinuz` (14.62 MB) e `initrd.img` (218.16 MB) por HTTP a 1 Gbps e inicia la instalacion desatendida via Kickstart (`ks.cfg`).

```text
[ Laptop Windows 11 ] (Gateway: 192.168.137.1)
  │  ├── Conexión Compartida (ICS): Enruta tráfico de Wi-Fi hacia Ethernet
  │  ├── Servidor HTTP (Puerto 8000): Sirve boot.ipxe, ks.cfg, vmlinuz e initrd.img
  │  ├── Servidor TFTP (Puerto 69): Sirve undionly.kpxe (iPXE)
  │  └── Servidor DHCP/ProxyDHCP (Puerto 67): Responde con opciones PXE dinámicas
  │
  ▼ (Cable Ethernet Gigabit - 1 Gbps)
[ HP ProLiant ML150 G6 ] (Puerto Inferior 1/Mgmt - NC107i Gigabit)
  1. BIOS PXE ROM solicita IP -> Recibe 192.168.137.50 y next-server=undionly.kpxe
  2. TFTP descarga undionly.kpxe en ~150 ms
  3. iPXE arranca -> Solicita DHCP con Opción 175
  4. DHCP detecta iPXE -> Entrega URL http://192.168.137.1:8000/boot.ipxe
  5. iPXE descarga vmlinuz (~15 MB) e initrd.img (~228 MB) por HTTP a 1 Gbps (~2-3 seg)
  6. Anaconda inicia en modo texto desatendido leyendo ks.cfg
  7. Instalación automatizada completa de AlmaLinux 9 y reinicio con OpenSSH activo
```

## 3. Resolucion del Bucle Infinito de iPXE
Para evitar que el cliente iPXE descargue cíclicamente su propio binario en entornos headless, el servidor DHCP implementa discriminación por cabeceras RFC 2132 / RFC 3925:
- **Cliente BIOS Estándar (Sin Opción 175):** Se le entrega `undionly.kpxe` vía TFTP.
- **Cliente iPXE (Con Opción 175 o User-Class 'iPXE'):** Se le entrega la directiva HTTP directa `http://192.168.137.1:8000/boot.ipxe`.

## 4. Parametros Kickstart (ks.cfg) para Operacion Headless
- Modo texto estricto (`text`, `skipx`).
- Aceptación automática de licencia (`eula --agreed`).
- Particionamiento automático MBR/BIOS (`bootloader --location=mbr`, `clearpart --all --initlabel`, `autopart --type=plain`).
- Red por DHCP en enlace activo (`network --bootproto=dhcp --device=link --activate --onboot=yes`).
- Contraseña de root preconfigurada (`rootpw --plaintext nexusadmin2026!`).
- SSH habilitado automáticamente (`services --enabled="sshd"`).
- Reinicio automático al terminar (`reboot`).

## 5. Pruebas de Diagnóstico y Resultados de Campo con el Servidor (Noviembre 2026)

Durante las sesiones de laboratorio y pruebas en vivo con el HP ProLiant ML150 G6 se ejecutaron y validaron los siguientes componentes:

### 5.1 Diagnóstico de Video y Descubrimiento del Estado del Servidor
- **Prueba:** Conexión del puerto VGA trasero hacia TV mediante adaptador activo VGA a HDMI.
- **Resultado:** El convertidor activo requería alimentación externa de 5V micro-USB para energizar el circuito analógico-digital. Al energizarlo por USB, la señal de video apareció de forma inmediata.
- **Hallazgo:** La pantalla reveló que el servidor tiene preinstalado **Windows Server 2008 R2 Enterprise** en un arreglo SAS RAID administrado por la controladora **HP Smart Array P410**.

### 5.2 Pruebas de Red y Sondeo DHCP/ICS
- **Entorno:** Conexión compartida a Internet (ICS) en Windows 11 sobre el segmento `192.168.137.0/24` (laptop como Gateway en `192.168.137.1`).
- **Scripts de Diagnóstico con Timeouts Estrictos (Mandato 6):**
  - `scripts/scan-ics-range.ps1`: Escaneo paralelo de direcciones IP en la subred ICS.
  - `scripts/detect-ilo.ps1`: Sondeo de puertos HTTP (80) y HTTPS (443) para identificar la interfaz HP iLO 100i con timeout de 2 segundos por nodo.
  - `scripts/monitor-hp-ip.ps1`: Monitoreo continuo de solicitudes ARP y asignaciones de IP para el servidor.
  - `scripts/check-dhcp-leases.ps1`: Inspección de concesiones de red emitidas por ICS.
  - `scripts/sniff-broadcasts.ps1` y `scripts/sniff-ports.ps1`: Captura no bloqueante de tramas DHCP UDP 67/68 y TFTP UDP 69.
- **Conclusión de Red:** El servidor físico no realizaba broadcast DHCP PXE durante el encendido debido a que la secuencia de arranque del BIOS priorizaba el disco duro interno Smart Array P410.

### 5.3 Implementación y Verificación del Servidor PXE Autónomo
- **Componente:** `scripts/headless_pxe_server.py` implementado en Python estándar sin dependencias externas pesadas.
- **Servicios Integrados:**
  - Servidor DHCP/ProxyDHCP en puerto UDP 67.
  - Servidor TFTP en puerto UDP 69 sirviendo `undionly.kpxe`.
  - Servidor HTTP en puerto TCP 8000 sirviendo `boot.ipxe`, `ks.cfg`, `vmlinuz` (14.62 MB) e `initrd.img` (218.16 MB).
- **Control de Bucle:** Discriminación de Opción 175 verificada para entrega directa del script de arranque HTTP al detectar clientes iPXE.
- **Lanzador Rápido:** Creación de `iniciar-servidor-pxe.bat` para ejecución en Windows 11 con elevación de privilegios de red.

### 5.4 Grabación Desatendida de iPXE en CD-R
- **Desafío:** Imposibilidad de grabar el ISO completo de AlmaLinux 9 (1.55 GB) en un CD-R virgen (700 MB) y ausencia de teclado físico USB conectado al servidor para cambiar el orden de arranque en el BIOS.
- **Solución:** Grabación de la imagen ultraligera `ipxe.iso` (9 MB) en CD-R.
- **Herramienta:** Creación de `scripts/burn-iso.ps1`, automatizando `C:\Windows\System32\isoburn.exe /Q E: C:\Users\lenin\pxeboot\ipxe.iso` sobre la unidad óptica externa PHILIPS CDRW/DVD SCB5265 (Unidad E:).
- **Resultado:** Grabación de pistas finalizada exitosamente con código de salida 0, lista para ser leída por la lectora frontal del servidor y conectar por Gigabit al servidor PXE de la laptop.

### 5.5 Diagnóstico de Beeps del BIOS, Arreglo SAS y Validación de Hardware
- **Comportamiento con Discos Extraídos (2 Beeps Cortos):**
  - Al extraer las dos charolas de discos SAS frontales hacia afuera para evitar el inicio de Windows Server, la controladora Smart Array P410 emitió 2 beeps cortos y pausó el POST en la advertencia `1785-Slot X Drive Array - Drive(s) Not Detected (Press F1 to continue)`.
  - Sin confirmación, el servidor se mantuvo esperando en pausa preventiva.
- **Comportamiento con Discos Reinsertados (1 Beep Corto):**
  - Al reinsertar y bloquear las dos charolas de discos SAS (450 GB 15K RPM HP Spare 517352-001) y reiniciar, el servidor emitió un único beep corto (POST exitoso y saludable).
  - El BIOS reconoció 8192 MB (8 GB) limpios en las ranuras primarias blancas `DIMM2A` y `DIMM4B` con módulos Micron/IBM DDR3 ECC Registered.

### 5.6 Configuración del BIOS Setup y Bloqueo Definitivo de Windows
- **Acceso a Setup de Firmware:** Entrada interactiva confirmada con tecla **`F10`** (o `Supr` / Delete).
- **Parámetros Validados:**
  - Placa Base: HP ProLiant ML150 G6, ROMID 021, ROM Revision 01/18/2011.
  - Procesador: Intel Xeon E5504 @ 2.00GHz (1 procesador físico, 4 cores).
  - Red Onboard: MAC `44:1E:A1:6E:D2:E4` (HP NC107i / Broadcom MBA v11.0.8).
  - Prioridad de Arranque USB: `USB Device Boot Priority: [High]`.
- **Orden de Arranque Establecido (Pestaña Boot):**
  - `1st Boot Device:` **`[CD/DVD]`**
  - `2nd Boot Device:` **`[Network:MBA v11.0.]`**
  - `3rd Boot Device:` **`[Disabled]`** (📌 Deshabilitación total de `[Hard Drive]`).
- **Efecto de Bloqueo:** El sistema preexistente Windows Server 2008 R2 Enterprise (dominio gubernamental `gppan.senado.gob.mx\administrador`) queda 100% inhabilitado para arrancar.
- **Estado de Halt y Señal de Vídeo:** Al fallar la lectura del CD y agotarse los intentos de PXE, el BIOS ejecuta un ciclo de Halt / Boot Failure. La controladora gráfica Matrox G200e desconecta la sincronización VGA analógica, provocando que el conversor activo muestre en la TV LG el mensaje de **"Sin señal"**.

### 5.7 Refactorización del Servidor PXE Autónomo (Subnet Directed Broadcast)
- **Diagnóstico del Fallo de Negociación DHCP:**
  - En Windows 11 con múltiples interfaces activas (Wi-Fi + Ethernet Realtek + adaptadores virtuales VMware/WSL), los paquetes dirigidos a la dirección de difusión universal `255.255.255.255:68` son enrutados por el kernel hacia la interfaz con la ruta predeterminada (Wi-Fi), impidiendo que el cliente en el enlace directo Ethernet reciba el `DHCPOFFER`.
  - La inclusión de la Opción DHCP 60 (`PXEClient`) en el puerto 67 instruye al cliente PXE a ignorar el `bootfile` y buscar un ProxyDHCP externo en el puerto 4011.
- **Correcciones Implementadas en `headless_pxe_server.py`:**
  1. **Subnet Directed Broadcast:** Se transmite tanto a `192.168.137.255:68` como a `255.255.255.255:68`, garantizando la salida física del paquete por la NIC Ethernet local.
  2. **Depuración de Opción 60:** Eliminación de la Opción 60 en las respuestas del puerto 67, permitiendo que la ROM Broadcom MBA v11.0 tome el `bootfile` (`undionly.kpxe`) y la IP TFTP (`192.168.137.1`) de forma directa y unificada.
  3. **Multi-Socket Binding:** Enlace concurrente en `192.168.137.1:67/4011/69` y `0.0.0.0:67/4011/69` con hilos dedicados para TFTP y HTTP.

### 5.8 Resolución de Error SSL por Reloj de BIOS y Despliegue de BaseOS
- **Incidente de Certificados No Válidos (`curl: (60) SSL certificate problem`):**
  - Al iniciar el ramdisk Anaconda y cargar `dracut-initqueue`, la descarga de la imagen del instalador (`stage2`) falló repetidamente contra `https://repo.almalinux.org/...`.
  - Causa Raíz: El reloj en tiempo real (RTC) del servidor HP se encontraba en `Tue 01/18/2011` debido a la pila de BIOS agotada. Para las herramientas criptográficas modernas en 2011, los certificados SSL/TLS emitidos en 2025/2026 figuran con fecha futura (`certificate is not yet valid`).
- **Remediación en Tiempo Real en `boot.ipxe` y `ks.cfg`:**
  - Redirección del origen de paquetes a protocolo HTTP plano: `http://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/`.
  - Incorporación de parámetros de bypass de verificación en la línea de comando del kernel y Kickstart: `inst.noverifyssl` y `--noverifyssl`.
- **Resultado del Despliegue en Vivo:**
  - Descarga exitosa de `vmlinuz` (14 MB), `initrd.img` (218 MB), `boot.ipxe` y `ks.cfg` por HTTP local en el puerto 8000.
  - Activación del framebuffer de consola Matrox G200e (`mgag200drmfb`) en resolución de 128×48 caracteres.
  - Transferencia ininterrumpida de más de 1.4 GB de paquetes RPM base mediante la conexión compartida ICS de la laptop a velocidades de ~12 MB/s, procediendo al particionado desatendido del arreglo Smart Array P410 (`/dev/sda`).

### 5.9 Despacho de Arranque Multi-Opción con Fallback a Disco SAS (`sanboot 0x80`)
- **Desafío:** Pérdida recurrente de configuración en NVRAM del BIOS (batería CR2032 agotada) que revierte el equipo a los valores de fábrica de 2011, provocando bucles si el usuario no interviene en menos de 1 segundo en el menú BBS.
- **Solución iPXE:** Transformación de `boot.ipxe` en un menú selectivo con timeout de 3 segundos:
  - Opción por defecto: `sanboot --no-describe --drive 0x80` (ejecuta INT 13h directo sobre el MBR de la controladora Smart Array P410).
  - Opciones secundarias: Modo Rescate de Linux por red (`inst.rescue`) y Reinstalación desatendida Kickstart (`:reinstall`).
- **Resguardo y Versionado Oficial:** Copia de respaldo en `boot.ipxe.installer-backup` e incorporación de toda la suite de arranque (`headless_pxe_server.py`, `ks.cfg`, `boot.ipxe`) dentro del repositorio rastreado por Git en `server/pxe/` (Commit `39d8342`).

### 5.10 Vía B: Arquitectura de Red de Dos Fases (inst.stage2) y Mitigación de Triple Fault
- **Diagnóstico del Reinicio Temprano (Triple Fault en Modo Real BIOS):**
  - Durante las pruebas con los 8 GB RDIMM Micron estabilizados, la transferencia por red de `vmlinuz` (15 MB) e `initrd.img` (228 MB) culminó en exactamente 5 segundos a 1 Gbps (243 MB entregados).
  - Sin embargo, a los 35-45 segundos el servidor experimentó un reinicio automático de hardware.
  - Causa Raíz 1: En los kernels modernos de RHEL 9 / AlmaLinux 9 (Linux 5.14+), el parámetro heredado de 16 bits `vga=normal` se encuentra completamente deprecado; al intentar invocar la llamada de selector de vídeo de BIOS en modo real, el kernel falla y dispara una excepción de CPU.
  - Causa Raíz 2: La BIOS AMI 2011 opera en modo real de 16-bit al despachar llamadas iPXE/UNDI; la descompresión en memoria contigua de un ramdisk de 228 MB (que en memoria alcanza 700+ MB) colisiona con el área EBDA y buffers de la Smart Array P410.
- **Implementación de la Vía B (Arranque Desatendido 100% Red Oficial):**
  - **Parámetro Obligatorio `inst.stage2`:** Se sustituye `inst.repo` por `inst.stage2=http://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os`, permitiendo a Dracut montar dinámicamente el entorno de Anaconda por streaming HTTP sin saturar la memoria baja.
  - **Depuración de Parámetros de Pantalla:** Se purga `vga=normal` y se fija `nomodeset inst.text console=tty0 console=ttyS0,115200n8`, estabilizando el conversor VGA a HDMI de la GPU Matrox MGA G200e.
  - **Alineación de Kickstart:** `selinux --permissive` y sincronización con `chronyd` para desacoplar el arranque del desfase temporal de la pila de litio agotada.
