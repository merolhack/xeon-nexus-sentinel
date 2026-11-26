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
* **Sistema Operativo Destino:** AlmaLinux 9.x Minimal (x86_64, sin interfaz gráfica). Instalación desatendida completada en arreglo RAID Smart Array P410 (`/dev/sda`).
* **Sistema Operativo Preexistente (Erradicado):** Windows Server 2008 R2 Enterprise (sobrescrito y particionado por Kickstart).
* **Modo Operativo:** Headless continuo (sin teclado ni monitor conectados en producción).
* **Propósito:** Nodo de cómputo en segundo plano para minería RandomX de baja prioridad, ejecución cuantizada de modelos ligeros con `llama.cpp` y recolección de métricas.

## 2. Puntos de Entrada y Control

* **HP iLO 100i (BMC):** Puerto Ethernet dedicado o compartido. Permite control de energía (power-on/reboot forzado) e inspección de salud térmica.
* **OpenSSH (Puerto 22):** Acceso administrativo seguro preconfigurado con usuario `root`, contraseña `nexusadmin2026!` y directiva `PermitRootLogin yes`.
* **Cockpit (Puerto 9090):** Panel web nativo para gestión de discos, red, paquetes y terminal web directa.
* **Daemon Local (xeon-sentinel):** Servicio systemd que recopila telemetría y controla el gobernador de alternancia.

## 3. Especificaciones de Hardware Verificadas en Laboratorio

* **Procesadores:** Dual Intel Xeon LGA1366 (Nehalem, 4 núcleos por zócalo, SSE4.2, triple canal de memoria DDR3 ECC).
* **Memoria RAM Verificada y Población de Slots:**
  * **Configuración Actual Operativa:** 8192 MB (8 GB) limpios en DDR3-1333 Registered ECC.
  * **Módulos Instalados:** 2 × Micron 4 GB `PC3-10600R` (`MT36JBZS51272PY-1G4D1`) en zócalos primarios blancos `DIMM 2A` y `DIMM 4B` de CPU1.
  * **Gobernanza de Memoria y Coexistencia:** Prohibición absoluta de mezcla entre módulos RDIMM y UDIMM (`PC3-10600E`). Los módulos preexistentes heredados (2x Nanya 4GB + 1x Samsung 2GB UDIMM) fueron desacoplados para garantizar la estabilidad eléctrica. (Véase detalle en [server-memory-and-bios-governance.md](../concepts/server-memory-and-bios-governance.md)).
* **Controlador de Almacenamiento:** HP Smart Array P410 con caché SAS/SATA y arreglo RAID activo.
* **Unidades de Disco Físicas (Identificadas en Bahías Hot-Plug):**
  * **Bahía 1:** 450 GB SAS 6G Dual-Port 15,000 RPM (HP Spare: `517352-001`).
  * **Bahía 2:** 450 GB SAS 6G Dual-Port 15,000 RPM (HP Spare: `517352-001`).
  * **Bahía 3:** Vacía.
  * **Bahía 4:** Bandeja ciega de relleno (Drive Blank Filler).
* **Puertos y Panel Frontal:**
  * 2 puertos frontales USB 2.0 (compatibles con teclado/mouse USB).
  * LEDs de estado: LED de encendido (Verde continuo), LED de salud del chasis (Verde continuo, confirmando salud operativa 100%), LED de actividad de red.
  * Botón de encendido frontal (Power/Standby con apagado forzado de 5 segundos).
* **Puertos de Red (NIC):** Dos puertos Gigabit integrados HP NC107i (Broadcom BCM5723):
  * **Puerto 1 / Mgmt (inferior):** Puerto Ethernet primario para PXE Netboot, enlace Gigabit con la laptop (192.168.137.1) y gestión.
  * **Puerto 2 (superior):** Puerto Ethernet secundario.
* **Video y Pantalla:** Chip gráfico Matrox G200 integrado con salida VGA trasera estándar.
* **Unidad Óptica:** Lector interno frontal DVD/CD SATA/IDE con bandeja motorizada (`hp DVDROM DH40N`).

## 4. Hallazgos y Resultados de las Pruebas Físicas (Noviembre 2026)

* **Diagnóstico de Video VGA a HDMI y Pérdida de Sincronismo:**
  * Se conectó un adaptador activo VGA a HDMI hacia una pantalla/TV HDMI LG.
  * El conversor activo requiere alimentación auxiliar de 5V micro-USB para energizar el circuito analógico-digital. Al energizarlo, la pantalla proyecta nítidamente el logo gráfico inicial de HP ProLiant.
  * Durante la transición del logo gráfico (640×480) hacia el modo texto (720×400 / Option ROMs), el puerto VGA reinicia momentáneamente la señal de sincronismo, causando que algunos convertidores pierdan el bloqueo de reloj y la TV muestre *"No hay señal"*.
* **Diagnóstico Acústico de Beeps de POST:**
  * **2 beeps cortos:** Ocurrieron al encender el servidor con las charolas de discos SAS extraídas hacia afuera. La controladora Smart Array P410 detectó la ausencia del arreglo (`1785-Slot X Drive Array - Drive(s) Not Detected`) y detuvo el POST esperando confirmación interactiva (`Press <F1> to continue, <F2> to configure`).
  * **1 beep corto:** Al volver a insertar los discos SAS en sus bahías y encender el servidor, sonó un único beep corto, el cual corresponde al código estándar de éxito de POST y transferencia de control hacia el dispositivo de arranque.
* **Intervención y Validación de Teclado y Setup de BIOS:**
  * Se confirmó la disponibilidad de teclado USB para la interacción directa con el firmware.
  * Tecla de acceso confirmada al BIOS Setup: **`F10`** (o `Supr` / Delete).
  * Firmware detectado: **AMI BIOS v02.61, ROMID 021, Fecha de Revisión 01/18/2011**.
  * Detección de Procesador: Intel(R) Xeon(R) CPU E5504 @ 2.00GHz (1 CPU físico, 4 de 4 cores lógicos habilitados).
  * Detección de Memoria: **`System Memory Size: 8192MB` (8 GB)** limpios y estables tras aislar los dos módulos nuevos VLP Micron/IBM 4 GB DDR3 ECC Registered en las ranuras primarias blancas `DIMM2A` y `DIMM4B`.
  * Dirección MAC integrada: **`44-1E-A1-6E-D2-E4`** (HP NC107i Gigabit / Broadcom MBA v11.0.8).
* **Despliegue y Conclusión Exitosa de AlmaLinux 9 vía Vía B (inst.stage2 Oficial):**
  * La instalación desatendida se ejecutó mediante arquitectura de red en dos fases con `inst.stage2=http://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os` y `inst.ks=http://192.168.137.1:8000/ks.cfg`.
  * Parámetros de pantalla optimizados: `nomodeset inst.text console=tty0 console=ttyS0,115200n8`, erradicando el parámetro obsoleto `vga=normal` que provocaba excepciones de CPU.
  * Se transfirieron más de 1.4 GB de paquetes RPM base a velocidades de entre 23 y 31 MB/s a través del enlace Gigabit de la laptop (`192.168.137.1`).
  * Anaconda completó el particionado de los discos SAS 15K RPM (`/dev/sda`), instaló el cargador GRUB en el MBR, ejecutó la configuración `%post` de SSH y sincronizador `chronyd`, y ejecutó el reinicio autónomo hacia el disco SAS local.
