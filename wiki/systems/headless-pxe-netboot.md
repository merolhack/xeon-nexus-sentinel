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

### 5.5 Diagnóstico de Beeps del BIOS, Arreglo SAS y Estrategia Cero-Teclado
- **Comportamiento con Discos Extraídos (2 Beeps Cortos):**
  - Al extraer las dos charolas de discos SAS frontales hacia afuera para evitar el inicio de Windows Server, la controladora Smart Array P410 emitió 2 beeps cortos y pausó el POST en la advertencia `1785-Slot X Drive Array - Drive(s) Not Detected (Press F1 to continue)`.
  - Sin teclado físico conectado, el servidor se mantuvo esperando confirmación, manteniendo los ventiladores y LEDs de estado en verde.
- **Comportamiento con Discos Reinsertados (1 Beep Corto):**
  - Al reinsertar y bloquear las dos charolas de discos SAS (450 GB 15K RPM HP Spare 517352-001) y reiniciar, el servidor emitió un único beep corto (POST exitoso y saludable).
  - El BIOS dio paso al cargador de arranque en disco, mostrando la pantalla de recuperación "Iniciar Windows normalmente" y continuando hacia "Aplicando la configuración del equipo".
  - Durante esta fase se confirmó el enlace físico Gigabit activo en la laptop (`Ethernet` Realtek GbE) con incremento de bytes recibidos (+31 KB).
- **Estrategia Headless sin Teclado (Ratón USB + Accesibilidad + Diskpart Clean):**
  - El servidor opera bajo la restricción estricta de **cero teclado físico**.
  - Se cuenta con un ratón USB conectado a los puertos frontales. A través del menú de Accesibilidad en la pantalla de bienvenida de Windows Server, se activa el Teclado en Pantalla (`osk.exe`) para enviar `Ctrl+Alt+Supr`.
  - En la siguiente sesión, desde Windows o la consola de recuperación WinRE, se ejecutará `diskpart -> select disk 0 -> clean` para borrar la tabla MBR de Windows Server. Al quedar el disco sin cargador pero físicamente presente y saludable, la Smart Array no dará error y el BIOS caerá automáticamente hacia el CD-R de iPXE o PXE Netboot para la instalación desatendida de AlmaLinux 9.
