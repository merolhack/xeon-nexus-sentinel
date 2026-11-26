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
* **Intervención y Validación de Teclado y Setup de BIOS:**
  * Se confirmó la disponibilidad de teclado USB para la interacción directa con el firmware.
  * Tecla de acceso confirmada al BIOS Setup: **`F10`** (o `Supr` / Delete).
  * Firmware detectado: **AMI BIOS v02.61, ROMID 021, Fecha de Revisión 01/18/2011**.
  * Detección de Procesador: Intel(R) Xeon(R) CPU E5504 @ 2.00GHz (1 CPU físico, 4 de 4 cores lógicos habilitados).
  * Detección de Memoria: **`System Memory Size: 8192MB` (8 GB)** limpios y estables tras aislar los dos módulos nuevos VLP Micron/IBM 4 GB DDR3 ECC Registered en las ranuras primarias blancas `DIMM2A` y `DIMM4B`.
  * Dirección MAC integrada: **`44-1E-A1-6E-D2-E4`** (HP NC107i Gigabit / Broadcom MBA v11.0.8).
* **Bloqueo Definitivo de Windows y Configuración de Arranque:**
  * El sistema preexistente en los discos SAS de 450 GB es **Windows Server 2008 R2 Enterprise** bajo el dominio gubernamental `gppan.senado.gob.mx\administrador` (bloqueado sin credenciales locales).
  * Para erradicar el secuestro del ciclo de arranque por parte de Windows sin necesidad de formateo previo:
    1. En la pestaña `Boot` del BIOS Setup se configuró:
       - `1st Boot Device:` **`[CD/DVD]`**
       - `2nd Boot Device:` **`[Network:MBA v11.0.]`**
       - `3rd Boot Device:` **`[Disabled]`** ➔ Bloqueo definitivo del disco duro SAS (`Hard Drive`).
    2. Comportamiento resultante: El servidor ya no puede cargar Windows Server. Tras agotar los intentos de lectura de CD y de negociación PXE, el BIOS entra en estado `Halt / Boot Failure`.
    3. Comportamiento de vídeo Matrox G200e con conversor activo VGA a HDMI: Al cesar la actividad de arranque y entrar en reposo la CPU, la controladora gráfica apaga la sincronización de vídeo VGA, mostrando la TV LG el mensaje de **"Sin señal"**.
    4. Tráfico PXE en tiempo real: Se verificó que la ROM Broadcom MBA v11.0 genera solicitudes `DHCP DISCOVER` repetitivas en el puerto 67 UDP hacia la laptop (`192.168.137.1`), lista para recibir paquetes de arranque de red.
* **Arranque Exitoso del Kernel de Linux y Detección de Dispositivos (AlmaLinux 9):**
  * **Almacenamiento SAS:** La controladora HP Smart Array P410 fue inicializada y reconocida como dispositivo SCSI primario: `sd 0:1:0:0: [sda] Attached SCSI disk` (`/dev/sda`), habilitando el particionamiento directo sobre el arreglo de 450 GB.
  * **Controladora Gráfica y Framebuffer:** El driver del kernel `mgag200` tomó el chip gráfico Matrox G200e (`0000:03:00.0`), activando el framebuffer de consola `mgag200drmfb (fb0)` en resolución 128×48 caracteres. Esto restableció la señal de vídeo continua en la TV LG sin desconexiones.
  * **Interfaz de Red Gigabit:** Driver `tg3` (Broadcom BCM5723) negoció enlace Gigabit a 1000 Mbps Full Duplex (`enp4s0: Link is up at 1000 Mbps, full duplex`).
  * **Unidad Óptica:** Identificada como `hp DVDROM DH40N` (`scsi 3:0:0:0: CD-ROM`).
  * **Resolución de Error SSL por Desfase Temporal del BIOS:** El instalador inicialmente arrojó `curl: (60) SSL certificate problem: certificate is not yet valid` debido a que el reloj del BIOS se encuentra en el año 2011 (`01/18/2011`), provocando que los certificados HTTPS actuales de los espejos fueran considerados no válidos. Se solventó redirigiendo los repositorios a HTTP plano (`http://repo.almalinux.org/...`) y agregando `inst.noverifyssl`, logrando la transferencia ininterrumpida de más de 1.4 GB de paquetes.
