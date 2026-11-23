---
type: entity
title: "Nodo Físico: Servidor HP ProLiant ML150 G6"
description: "Servidor empresarial torre de doble zócalo Xeon operando en modo headless con AlmaLinux 9 Minimal"
tags: [servidor, hp-proliant, almalinux, headless, ilo, xeon, smart-array, ipxe]
created: 2026-11-22
updated: 2026-11-23
---

# Nodo Físico: Servidor HP ProLiant ML150 G6 (`hp-server-node`)

## 1. Identificación y Rol

* **Hostname Local:** `xeon-sentinel.local` o IP estática en red interna.
* **Sistema Operativo Destino:** AlmaLinux 9.x Minimal (x86_64, sin interfaz gráfica).
* **Sistema Operativo Preexistente (Detectado):** Windows Server 2008 R2 Enterprise (instalado en disco).
* **Modo Operativo:** Headless continuo (sin teclado ni monitor conectados en producción).
* **Propósito:** Nodo de cómputo en segundo plano para minería RandomX de baja prioridad, ejecución cuantizada de modelos ligeros con `llama.cpp` y recolección de métricas.

## 2. Puntos de Entrada y Control

* **HP iLO 100i (BMC):** Puerto Ethernet dedicado o compartido. Permite control de energía (power-on/reboot forzado) e inspección de salud térmica.
* **OpenSSH (Puerto 22):** Acceso administrativo seguro mediante llave criptográfica `ed25519` y autenticación de root preconfigurada en Kickstart.
* **Cockpit (Puerto 9090):** Panel web nativo para gestión de discos, red, paquetes y terminal web directa.
* **Daemon Local (xeon-sentinel):** Servicio systemd que recopila telemetría y controla el gobernador de alternancia.

## 3. Especificaciones de Hardware Verificadas en Laboratorio

* **Procesadores:** Dual Intel Xeon LGA1366 (Nehalem, 4 núcleos por zócalo, SSE4.2, triple canal de memoria DDR3 ECC).
* **Controlador de Almacenamiento:** HP Smart Array P410 con caché SAS/SATA y arreglo RAID activo.
* **Unidades de Disco Físicas (Identificadas en Bahías Hot-Plug):**
  * **Bahía 1:** 450 GB SAS 6G Dual-Port 15,000 RPM (HP Spare: `517352-001`).
  * **Bahía 2:** 450 GB SAS 6G Dual-Port 15,000 RPM (HP Spare: `517352-001`).
  * **Bahía 3:** Vacía.
  * **Bahía 4:** Bandeja ciega de relleno (Drive Blank Filler).
* **Puertos y Panel Frontal:**
  * 2 puertos frontales USB 2.0 (compatibles con ratón/mouse USB y almacenamiento).
  * LEDs de estado: LED de encendido (Verde continuo), LED de salud del chasis (Verde continuo, confirmando salud operativa 100%), LED de actividad de red.
  * Botón de encendido frontal (Power/Standby con apagado forzado de 5 segundos).
* **Puertos de Red (NIC):** Dos puertos Gigabit integrados HP NC107i (Broadcom BCM5723):
  * **Puerto 1 / Mgmt (inferior):** Puerto Ethernet primario para PXE Netboot, enlace Gigabit con la laptop (192.168.137.1) y gestión.
  * **Puerto 2 (superior):** Puerto Ethernet secundario.
* **Video y Pantalla:** Chip gráfico Matrox G200 integrado con salida VGA trasera estándar.
* **Unidad Óptica:** Lector interno frontal DVD/CD SATA/IDE con bandeja motorizada.

## 4. Hallazgos y Resultados de las Pruebas Físicas (Noviembre 2026)

* **Diagnóstico de Video VGA a HDMI y Pérdida de Sincronismo:**
  * Se conectó un adaptador activo VGA a HDMI hacia una pantalla/TV HDMI LG.
  * El conversor activo requiere alimentación auxiliar de 5V micro-USB para energizar el circuito analógico-digital. Al energizarlo, la pantalla proyecta nítidamente el logo gráfico inicial de HP ProLiant.
  * Durante la transición del logo gráfico (640×480) hacia el modo texto (720×400 / Option ROMs), el puerto VGA reinicia momentáneamente la señal de sincronismo, causando que algunos convertidores pierdan el bloqueo de reloj y la TV muestre *"No hay señal"*.
* **Diagnóstico Acústico de Beeps de POST:**
  * **2 beeps cortos:** Ocurrieron al encender el servidor con las charolas de discos SAS extraídas hacia afuera. La controladora Smart Array P410 detectó la ausencia del arreglo (`1785-Slot X Drive Array - Drive(s) Not Detected`) y detuvo el POST esperando confirmación interactiva (`Press <F1> to continue, <F2> to configure`).
  * **1 beep corto:** Al volver a insertar los discos SAS en sus bahías y encender el servidor, sonó un único beep corto, el cual corresponde al código estándar de éxito de POST y transferencia de control hacia el dispositivo de arranque.
* **Comportamiento del Sistema Operativo en Disco:**
  * La pantalla de recuperación de Windows apareció tras el apagado previo ("Iniciar Windows normalmente") y continuó automáticamente hacia *"Aplicando la configuración del equipo"*.
  * Esto confirmó la total integridad del hardware: placa base, CPUs Xeon, módulos de memoria ECC y controladora Smart Array P410 están al 100% operativos.
  * Durante el arranque de Windows, la interfaz física `Ethernet` en la laptop registró actividad de recepción de red (+31 KB).
* **Estrategia Operativa Headless sin Teclado Físico (Cero-Keyboard):**
  * Se estableció como premisa definitiva que el servidor **no cuenta ni contará con teclado USB físico**.
  * Se cuenta con un **ratón/mouse USB** conectado a los puertos frontales del servidor.
  * Mediante el icono de **Facilidad de acceso (Accesibilidad)** en la esquina inferior izquierda de la pantalla de bienvenida de Windows, se activa el **Teclado en Pantalla** (`osk.exe`) para enviar `Ctrl+Alt+Supr` y comandos administrativos con el ratón.
* **Estrategia para Forzar el Arranque Desatendido de AlmaLinux 9:**
  * Dado que el BIOS prioriza el disco duro local sobre el CD-ROM/PXE mientras exista un cargador de arranque en el MBR, la estrategia técnica consiste en:
    1. Acceder a Windows o al entorno de recuperación WinRE con el ratón y teclado en pantalla.
    2. Ejecutar `diskpart -> select disk 0 -> clean` para borrar la tabla de particiones y MBR de Windows Server.
    3. Al reiniciar, la Smart Array P410 detectará los discos sanos (sin 2 beeps de error), pero al no encontrar sistema operativo en disco, el BIOS caerá automáticamente al siguiente dispositivo: el **CD-R con iPXE** o **PXE Netboot**.
    4. El instalador Anaconda Kickstart (`ks.cfg`) particionará e instalará AlmaLinux 9 de forma 100% desatendida.
