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
El servidor **HP ProLiant ML150 G6** es un nodo de computo headless:
- Sin monitor ni adaptador de video VGA activo.
- Sin teclado USB externo.
- Sin unidades flash USB ni lector/quemador de DVD (unicamente CD-R 700 MB).
- Conectado directamente por cable Ethernet Gigabit cruzado/directo a una laptop con Windows 11.

## 2. Topologia de Red y Flujo de Comunicacion

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
