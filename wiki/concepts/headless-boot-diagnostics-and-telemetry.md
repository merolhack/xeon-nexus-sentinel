---
type: concept
title: "Diagnóstico de Arranque Headless, Telemetría de Capa de Enlace y Automatización de iPXE"
description: "Patrones de diagnóstico sin monitor para servidores legados con fallas de sincronismo de vídeo, telemetría por velocidad de enlace PHY (100M/1G) y arranque asistido por iPXE"
tags: [headless, pxe, ipxe, telemetry, matrox-g200, diagnostics, sanboot, cr2032, bios]
created: 2026-11-26
updated: 2026-11-26
---

# Diagnóstico de Arranque Headless, Telemetría de Capa de Enlace y Automatización de iPXE

Este documento compendia las técnicas avanzadas de telemetría de red, monitoreo de estados de hardware sin monitor y automatización de arranque diseñadas para operar con el nodo servidor **HP ProLiant ML150 G6** cuando la salida de vídeo analógica (Matrox G200e + conversor activo VGA-HDMI) es inestable o efímera.

---

## 1. El Desafío Físico: Cegueras Visuales en Hardware Legado

En servidores empresariales torre de generación G6/G7 (2009-2011), el monitoreo visual tradicional mediante monitores HDMI comerciales falla por tres razones físicas:
1. **Pérdida de Sincronismo del DAC Analógico:** El chip gráfico integrado **Matrox G200e** altera repetidamente sus frecuencias de refresco horizontal y vertical al conmutar entre el logotipo gráfico inicial (640×480 @ 60Hz), el modo texto del BIOS AMI (720×400 @ 70Hz), las Option ROMs de controladoras PCIe y el framebuffer del kernel Linux (`mgag200drmfb`).
2. **Desconexión del Conversor Activo VGA-HDMI:** Los conversores analógico-digitales comerciales pierden el enganche de fase (Phase-Locked Loop / PLL) ante transiciones de vídeo de menos de 500 ms, provocando que los televisores modernos (como LG) entren en modo de ahorro de energía (*"No signal / Power Saving Mode"*).
3. **Brevedad de Mensajes Críticos en Pantalla:** Avisos como `Press <ESC> to boot....1` duran exactamente un segundo antes de que la BIOS tome la decisión de arranque por defecto, haciendo humanamente imposible la verificación o captura visual interactiva.

---

## 2. Telemetría de Capa de Enlace (L2/PHY) como Monitor de Estado

Ante la ausencia de vídeo, el estado del hardware del servidor se infiere con precisión milimétrica analizando la velocidad de enlace (*LinkSpeed*) y el tráfico de tramas en la tarjeta de red Gigabit integrada (HP NC107i / Broadcom BCM5723):

```text
[Servidor Apagado / Standby]  ---> Link: Desconectado o 10 Mbps (solo BMC/iLO si está energizado)
[POST de BIOS / Setup F10]    ---> Link: 100 Mbps (Broadcom PHY en modo ahorro/compatibilidad BIOS)
[Option ROM Broadcom MBA]     ---> Link: 100 Mbps o 1 Gbps (Peticiones DHCP DISCOVER en puerto UDP 67)
[Kernel Linux / Driver tg3]   ---> Link: 1 Gbps (Negociación Full Duplex Gigabit 1000 Mbps)
```

### Regla Diagnóstica de Transición de Velocidad:
* **Si el enlace salta de 100 Mbps a 1 Gbps:** Significa inequívocamente que el hardware del servidor superó el POST y el kernel de Linux (o el firmware avanzado de red) tomó el control del bus PCI Express e inicializó el controlador `tg3`. La falta de imagen es 100% atribuible al conversor de vídeo.
* **Si el enlace permanece en 100 Mbps indefinidamente:** El servidor continúa en la fase de BIOS o se encuentra en pausa por advertencia interactiva (`Press <F1> to continue` o `Press <ESC> to boot`).

---

## 3. Resiliencia Ante la Pérdida de NVRAM/CMOS (Batería CR2032)

Cuando la batería de litio CR2032 de la placa base se encuentra agotada (0.0 V):
1. **Microcaída de Tensión en Reinicio:** Durante un reinicio por software (*warm reset*), la línea de voltaje principal cae temporalmente para resetear el Southbridge (ICH10R). Sin la batería de 3V para sostener los registros CMOS, se genera un error de suma de verificación (*CMOS Checksum Bad*) y la placa carga los valores por defecto de fábrica de 2011.
2. **Estrategia de Mitigación por Red (Fallback de Fábrica):**
   * En los valores de fábrica, la BIOS del ML150 G6 busca unidades ópticas y luego ejecuta de forma obligatoria el arranque por red **PXE (`Network:MBA`)**.
   * Esto permite utilizar la laptop como un **orquestador maestro de rescate** que no depende de la memoria de la placa base.

---

## 4. Arquitectura de Arranque Automatizado con iPXE (`sanboot 0x80`)

Para garantizar que el servidor siempre cargue AlmaLinux 9 instalado en los discos duros SAS de la controladora Smart Array P410 sin importar la pérdida de configuración del BIOS, el script `boot.ipxe` en la laptop implementa un despachador inteligente:

```ipxe
#!ipxe
set menu-timeout 3000
set submenu-timeout ${menu-timeout}

:start
menu Xeon Nexus Sentinel - Menu de Inicio Automatizado
item --default --key s local_sas  [S] Arrancar AlmaLinux 9 desde Disco SAS Local (0x80)
item --key r rescue_boot          [R] Arrancar Modo Rescate de Linux por Red
item --key i reinstall            [I] Reinstalar AlmaLinux 9 (Kickstart Automatico)
choose --timeout ${menu-timeout} --default local_sas target && goto ${target}

:local_sas
echo Arrancando AlmaLinux 9 desde disco SAS local (0x80)...
sanboot --no-describe --drive 0x80 || goto fallback_exit

:fallback_exit
echo [AVISO] sanboot fallo o no respondio. Saliendo de iPXE...
exit 1
```

### Mecánica de Ejecución:
1. El servidor arranca por PXE y descarga `undionly.kpxe` vía TFTP.
2. iPXE ejecuta `boot.ipxe` por HTTP local (puerto 8000).
3. Tras una cuenta regresiva de 3 segundos, `sanboot --no-describe --drive 0x80` invoca directamente la interrupción BIOS INT 13h sobre el dispositivo `0x80` (el arreglo RAID 1 de 419 GB de la Smart Array P410).
4. El MBR de AlmaLinux 9 toma el control y carga el sistema operativo de forma desatendida.

---

## 5. Matriz de Scripts de Diagnóstico Robusto (Suite Headless)

Para diagnosticar sin depender de la salida de vídeo, se establecen cuatro monitores automáticos en la estación de control:

| Script | Propósito | Detección Clave |
| :--- | :--- | :--- |
| `monitor-link-speed.ps1` | Monitorea la velocidad de enlace físico (100M vs 1G). | Distingue entre estado BIOS (100M) y estado Linux Kernel (1G). |
| `sniff-dhcp-traffic.py` | Escucha pasiva de tramas DHCP DISCOVER/REQUEST en puerto 67 UDP. | Identifica si el servidor está en fase de arranque PXE ROM o de cliente OS. |
| `scan-active-ssh.py` | Barrido asíncrono con timeout corto (0.3 s) sobre subred `192.168.137.0/24`. | Detecta la apertura inmediata del puerto 22 SSH al terminar el boot. |
| `recover-vga-hdmi.bat` | Reseteo por software de alimentación de concentradores USB vinculados al conversor. | Fuerza el reenganche de fase analógica en pantallas externas. |
