---
title: "Arquitectura de Despliegue Headless PXE Netboot para HP ProLiant ML150 G6"
description: "Servidor PXE/TFTP/HTTP autonomo en Python para instalacion desatendida de AlmaLinux 9 en servidores sin monitor ni teclado."
category: "systems"
date: "2026-11-22"
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
