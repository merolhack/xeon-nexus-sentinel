# XEON-NEXUS-SENTINEL-LLM-WIKI-MASTER.md — Compendio Maestro de Conocimiento Xeon-Nexus-Sentinel
- **Notebook URL:** https://notebook.google.com/notebook/1bd607be-628c-4228-a1f5-5b4f5dd59093
- **Arquitectura:** Google OKF v0.2 + Karpathy 3-Layer LLM Wiki (`raw/`, `wiki/`, `SPEC.md`)
- **Archivos Compilados:** 22
- **SHA-256:** `4a7d9550380120371b83b1307b32e83a2e3ec0d793e84120a0a431526e8bd36e`
- **Fecha de Compilación:** 2026-11-26T17:20:33.993Z


================================================================================
# FILE: AGENTS.md
================================================================================

# AGENTS.md — Manual Operativo y Directivas de Ingeniería para Agentes de IA

Este documento establece las **reglas estrictas y de cumplimiento obligatorio** para cualquier agente de Inteligencia Artificial (Antigravity IDE, Gemini CLI, Claude, subagentes) o desarrollador que interactúe, genere o modifique código en el repositorio `merolhack/xeon-nexus-sentinel`.

---

## 1. Reglas Estrictas y Mandatos Inmutables

> [!IMPORTANT]
> **MANDATOS OBLIGATORIOS (PRIORIDAD CRÍTICA):**
>
> 1. **Usar `ollama-local` con el modelo `qwen3:8b-8k`:**
>    - Para tareas mecánicas, boilerplate repetitivo, formateo o generación auxiliar de baja complejidad, se debe delegar prioritariamente en la herramienta MCP `consultar_modelo_local` del servidor `ollama-local`.
>    - La herramienta consulta primero `gemma4:cloud` si hay cuota disponible y cae automáticamente al modelo local `qwen3:8b-8k`.
>    - Queda estrictamente prohibido intentar invocar comandos interactivos en consola (`ollama run`) que puedan bloquear la terminal.
>
> 2. **Siempre leer y actualizar la LLM Wiki como memoria del proyecto:**
>    - Antes de analizar o modificar cualquier componente, el agente DEBE leer `index.md` y los artículos relevantes en `wiki/` (`systems/`, `concepts/`, `entities/`).
>    - Al concluir cada tarea o sesión de trabajo, es OBLIGATORIO registrar los cambios en `log.md` y actualizar la página temática de `wiki/` correspondiente para evitar regresiones y pérdida de contexto.
>
> 3. **Siempre eliminar archivos `Zone.Identifier`:**
>    - El entorno híbrido Windows 11 + WSL genera artefactos NTFS de seguridad (archivos `*:Zone.Identifier` o `*Zone.Identifier*`).
>    - El agente DEBE ejecutar rutinariamente la limpieza preventiva de estos archivos (`npm run clean:zones` o `find . -name "*Zone.Identifier*" -delete`) antes de crear commits, ejecutar tests o indexar el repositorio.
>    - Ningún archivo `Zone.Identifier` debe ingresar al árbol de control de versiones de Git.
>
> 4. **Siempre actualizar Codebase Memory:**
>    - Este proyecto utiliza `codebase-memory` para mantener un grafo de conocimiento semántico (LSP, rutas, funciones y llamadas).
>    - Usar prioritariamente las herramientas MCP del grafo (`search_graph`, `trace_path`, `get_code_snippet`, `query_graph`, `index_status`) antes de recurrir a búsquedas textuales ciegas (`grep`/`find`).
>    - Tras añadir, renombrar o refactorizar archivos de código o servicios, es OBLIGATORIO ejecutar `index_repository` para refrescar el grafo.
>
> 5. **Siempre actualizar Gemini Notebook y solicitar confirmación de actualización:**
>    - El cuaderno oficial de Gemini Notebook para este proyecto es:
>      `https://notebook.google.com/notebook/1bd607be-628c-4228-a1f5-5b4f5dd59093` (ID de biblioteca: `xeon-nexus-sentinel`).
>    - Tras cualquier modificación en la wiki, arquitectura o código clave, el agente DEBE sincronizar el compendio maestro con Gemini Notebook ejecutando `npm run wiki:sync-notebook` o utilizando las herramientas MCP de `notebooklm-mcp` (`add_source`).
>    - El agente DEBE solicitar confirmación explícita al usuario para verificar la actualización en el cuaderno y presentar el resumen de los cambios sincronizados.
>
> 6. **Prevención de Bloqueos por Timeout (Anti-Hang y Timeouts Estrictos):**
>    - Queda terminantemente prohibido ejecutar comandos de red, pruebas de conectividad o descargas (`curl`, `Invoke-WebRequest`, sockets, escaneos de puertos) sin un timeout explícito y corto (máximo 5 a 10 segundos, ej: `curl --max-time 10`, `-TimeoutSec 5`).
>    - Prohibido enviar comandos de sondeo simple o verificación ligera a tareas en segundo plano sin guardia de tiempo; procesos colgados sin timeout congelan la sesión del agente por decenas de minutos.
>    - Toda verificación de red debe ejecutarse de forma acotada y si un endpoint no responde en 5 segundos, abortar de inmediato y continuar el flujo sin bloquear al usuario.

---

## 2. Prohibición Terminante de Sintaxis LaTeX / MathJax

> [!CAUTION]
> **CERO LATEX / MATHJAX EN CHAT, DOCUMENTOS, CÓDIGO Y WIKI:**
> Antigravity IDE, NotebookLM, GitHub y los terminales CLI no renderizan comandos TeX/LaTeX y muestran el texto fragmentado y roto.
> - **PROHIBIDO:** Usar `$...$`, `$$...$$`, `\( ... \)`, `\[ ... \]` o comandos de barra invertida (`\rightarrow`, `\le`, `\ge`, `\times`, `\pm`, `\frac`, `\text{...}`).
> - **OBLIGATORIO:** Usar exclusivamente caracteres legibles Unicode (`→`, `←`, `≤`, `≥`, `×`, `±`, `≠`, `≈`), ASCII estándar (`->`, `<=`, `>=`, `*`, `!=`) o emojis semánticos (`✅`, `⚠️`, `❌`, `📌`, `🚀`).

---

## 3. Arquitectura del Repositorio y Matriz de Componentes

| Directorio | Propósito | Tecnologías Clave |
| :--- | :--- | :--- |
| `wiki/` | Memoria viva del proyecto según estándar Google OKF v0.2 | Markdown estructurado, Frontmatter YAML |
| `raw/` | Documentación inmutable de especificaciones y límites | Fichas técnicas de hardware y cuotas Cloud |
| `server/` | Daemon de telemetría y scripts de gobernanza para AlmaLinux 9 | Python 3, Systemd, NUMA, XMRig HTTP API, Ollama |
| `cloud-relay/` | Microservicio REST público para nubes SaaS gratuitas | Python 3.12, FastAPI, Uvicorn, JWT, Docker |
| `dashboard/` | Frontend estático publicado en GitHub Pages | Next.js 14+ (SSG), Tailwind CSS, TypeScript, Web Crypto |
| `scripts/` | Automatizaciones de mantenimiento, limpieza y sincronización | Node.js ESM, Bash, MCP Stdio Client |

---

## 4. Política de Cero Secretos en el Repositorio (Zero Secrets in VCS)

1. **Nunca realizar commit de credenciales reales:** No incluir contraseñas en claro, tokens de servidor (`X-Server-Token`), secretos JWT, claves SSH privadas ni API keys en ningún archivo rastreado por Git.
2. **Uso de Variables de Entorno:**
   - En el Cloud Relay: `ADMIN_USER`, `ADMIN_PASSWORD_HASH`, `JWT_SECRET_KEY`, `SERVER_INGEST_TOKEN`.
   - En el Servidor AlmaLinux: `server/daemon/config.yaml` debe utilizar rutas protegidas (`chmod 600`) o variables de entorno del sistema.
   - En GitHub Actions: Configurar secretos en el repositorio (`Settings → Secrets and variables → Actions`).

---

## 5. Protocolo de Ejecución de Tareas en Antigravity IDE

```text
[Inicio de Tarea]
       │
       ▼
1. Consultar LLM Wiki (index.md y wiki/) + Codebase Memory (search_graph)
       │
       ▼
2. Limpieza preventiva: scripts/clean-zone-identifiers.sh
       │
       ▼
3. Desarrollar/Refactorizar con tipado estricto y sin sintaxis LaTeX
       │
       ▼
4. Ejecutar validaciones y pruebas locales (Next.js export, Python syntax)
       │
       ▼
5. Actualizar documentación viva: wiki/, log.md e index.md
       │
       ▼
6. Actualizar Codebase Memory (index_repository)
       │
       ▼
7. Sincronizar con Gemini Notebook (scripts/sync-wiki-to-notebook.mjs)
       │
       ▼
8. Solicitar confirmación de actualización al usuario y verificar GitHub Actions
```


================================================================================
# FILE: SPEC.md
================================================================================

# SPEC.md — Especificación de Memoria Google OKF v0.2 + LLM Wiki

## 1. Visión General

Este repositorio implementa el estándar **Google Open Knowledge Format (OKF v0.2)** combinado con el patrón de diseño **Karpathy LLM Wiki**. Su objetivo es proporcionar una memoria estructurada, determinista y navegable para modelos de lenguaje y agentes de IA, eliminando la necesidad de RAG probabilístico en favor de conocimiento precompilado y enlaces explícitos.

## 2. Taxonomía de Documentos

Toda la base de conocimiento en `wiki/` y `raw/` se clasifica en los siguientes tipos formales:

| Tipo | Directorio | Descripción | Mutabilidad |
| :--- | :--- | :--- | :--- |
| `raw` | `raw/` | Documentos fuente inmutables, manuales de fabricante y especificaciones técnicas | Solo lectura (Inmutable) |
| `system` | `wiki/systems/` | Componentes de software y servicios ejecutables del ecosistema | Versionado continuo |
| `concept` | `wiki/concepts/` | Principios teóricos, decisiones de diseño, algoritmos y protocolos | Versionado continuo |
| `entity` | `wiki/entities/` | Nodos físicos, servidores, dispositivos y recursos computacionales | Versionado continuo |
| `spec` | Raíz (`SPEC.md`) | Metarreglas y esquemas que definen la estructura de la memoria | Estable |

## 3. Esquema de Frontmatter Obligatorio (OKF v0.2)

Cada archivo en `wiki/` DEBE contener un bloque YAML formal de encabezado con los siguientes atributos:

```yaml
---
type: concept | system | entity | spec
title: "Título Descriptivo y Preciso"
description: "Resumen conciso en una o dos oraciones para indexación rápida por el LLM"
tags: [etiqueta-1, etiqueta-2, etiqueta-3]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

## 4. Estructura de Navegación del Grafo

- **`index.md`**: Punto de entrada canónico del agente. Contiene el mapa de relaciones entre sistemas, conceptos y entidades físicas.
- **`log.md`**: Bitácora cronológica acumulativa (append-only) que documenta las sesiones de trabajo, decisiones arquitectónicas y cambios de infraestructura.
- **`AGENTS.md`**: Manual de conducta y directivas operacionales del agente.


================================================================================
# FILE: index.md
================================================================================

# Índice Maestro del Grafo de Conocimiento (LLM Wiki)

Bienvenido a la memoria central de **Xeon-Nexus-Sentinel**. Este índice es la raíz de navegación para agentes de IA y desarrolladores.

---

## 🗺️ Mapa de Navegación del Ecosistema

```text
                           [index.md] (Raíz)
                               │
       ┌───────────────────────┼───────────────────────┐
       ▼                       ▼                       ▼
  [wiki/systems/]        [wiki/concepts/]        [wiki/entities/]
  - almalinux-daemon     - cpu-inference-tuning  - hp-server-node
  - cloud-relay-api      - randomx-isolation     - windows-laptop-node
  - nextjs-dashboard     - static-client-auth
                               │
                               ▼
                         [raw/ Documentación Inmutable]
                         - hp-ml150-g6-specs
                         - intel-xeon-lga1366
                         - free-tier-limits
```

---

## 📚 Catálogo de Documentos Compilados

### 1. Sistemas Operacionales (`wiki/systems/`)
* [almalinux-daemon.md](file:///wiki/systems/almalinux-daemon.md) — Agente en Python para recolección de telemetría de hardware y estado de procesos.
* [cloud-relay-api.md](file:///wiki/systems/cloud-relay-api.md) — Microservicio FastAPI para ingestión de telemetría y emisión de tokens de acceso en nubes gratuitas.
* [nextjs-dashboard.md](file:///wiki/systems/nextjs-dashboard.md) — Frontend estático exportado para GitHub Pages con panel interactivo y gráficos en tiempo real.
* [headless-pxe-netboot.md](file:///wiki/systems/headless-pxe-netboot.md) — Servidor PXE/TFTP/HTTP autónomo y pipeline de despliegue desatendido para servidores sin monitor ni teclado.

### 2. Conceptos y Protocolos de Ingeniería (`wiki/concepts/`)
* [cpu-inference-tuning.md](file:///wiki/concepts/cpu-inference-tuning.md) — Optimización de inferencia cuantizada (GGUF Q4_K_M) en arquitecturas Intel Xeon legadas sin AVX2.
* [randomx-cache-isolation.md](file:///wiki/concepts/randomx-cache-isolation.md) — Regla de afinidad y memoria caché L3 (2 MB por hilo) para minería RandomX y gobernanza con IA.
* [static-client-auth.md](file:///wiki/concepts/static-client-auth.md) — Esquema de autenticación criptográfica en el cliente mediante Web Crypto API y tokens JWT.
* [secrets-management-and-gitguardian.md](file:///wiki/concepts/secrets-management-and-gitguardian.md) — Gestión segura de credenciales, política de cero secretos y validación con GitGuardian y pre-commit hooks.
* [storage-optimization-and-gdrive-backup.md](file:///wiki/concepts/storage-optimization-and-gdrive-backup.md) — Optimización de disco local (Windows 11 / WSL2) y respaldos seguros en Google Drive con rclone (5 TiB).
* [execution-timeouts-and-anti-hang-patterns.md](file:///wiki/concepts/execution-timeouts-and-anti-hang-patterns.md) — Políticas estrictas de timeout y patrones anti-bloqueo en comandos de red y diagnóstico del agente.
* [strata-vs-ollama-inference.md](file:///wiki/concepts/strata-vs-ollama-inference.md) — Análisis arquitectónico de Strata Frameworks (MoE Qwen3.8/GLM), jerarquía de memoria y viabilidad frente a Ollama en CPU Xeon Nehalem.
* [server-memory-and-bios-governance.md](file:///wiki/concepts/server-memory-and-bios-governance.md) — Gobernanza de memoria DDR3 ECC (RDIMM vs UDIMM), reglas de coexistencia y configuración de arranque en BIOS y Smart Array P410.

### 3. Entidades de Hardware e Infraestructura (`wiki/entities/`)
* [hp-server-node.md](file:///wiki/entities/hp-server-node.md) — Servidor empresarial HP ProLiant ML150 G6 en modo headless con AlmaLinux 9 Minimal.
* [windows-laptop-node.md](file:///wiki/entities/windows-laptop-node.md) — Estación de trabajo Windows 11 con Antigravity IDE, Ollama y consola de administración remota.

### 4. Especificaciones y Referencias Inmutables (`raw/`)
* [hp-ml150-g6-specs.md](file:///raw/hardware/hp-ml150-g6-specs.md) — Manual de especificaciones y capacidades del servidor HP ProLiant ML150 G6.
* [intel-xeon-lga1366.md](file:///raw/hardware/intel-xeon-lga1366.md) — Características de arquitectura Nehalem/Westmere (SSE4.2, NUMA triple canal).
* [free-tier-limits.md](file:///raw/cloud/free-tier-limits.md) — Cuotas y límites operativos de Koyeb, Zeabur, Render y GitHub Pages.

---

## 🛠️ Bitácora y Operaciones
* [AGENTS.md](file:///AGENTS.md) — Directivas y reglas estrictas para agentes de IA.
* [SPEC.md](file:///SPEC.md) — Esquema OKF v0.2 de la memoria de conocimiento.
* [log.md](file:///log.md) — Bitácora de cambios y decisiones técnicas.


================================================================================
# FILE: wiki/entities/hp-server-node.md
================================================================================

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


================================================================================
# FILE: wiki/entities/windows-laptop-node.md
================================================================================

---
type: entity
title: "Nodo Workstation: Laptop Windows 11"
description: "Estación de trabajo principal para desarrollo agéntico con Antigravity IDE, Ollama y consola de control"
tags: [workstation, windows11, antigravity-ide, ollama, wsl2]
created: 2026-11-22
updated: 2026-11-22
---

# Nodo Workstation: Laptop Windows 11 (`windows-laptop-node`)

## 1. Identificación y Rol

* **Sistema Operativo:** Windows 11 Pro con subsistema WSL 2 (Ubuntu 20.04 LTS).
* **Entorno de Desarrollo:** Antigravity IDE (agente AI integrado con servidores MCP y LLM Wiki).
* **Motor de Inferencia Local:** Ollama Desktop para modelos locales de asistencia (`qwen3:8b-8k`, `gemma4`).
* **Propósito:** Estación de trabajo para el programador. Proporciona los periféricos físicos (pantalla, teclado y ratón) para administrar el servidor HP ProLiant a través de la red local.

## 2. Conectividad con el Servidor

* Conexión vía WiFi hacia el punto de acceso / repetidor compartido con el servidor.
* Sesiones de terminal OpenSSH y visualización del panel web de Cockpit en navegador.
* Gestión de repositorios en GitHub mediante `gh` CLI y flujos CI/CD.


================================================================================
# FILE: wiki/systems/nextjs-dashboard.md
================================================================================

---
type: system
title: "Frontend Next.js en GitHub Pages"
description: "Panel de control estático con autenticación en cliente para monitoreo de telemetría y estado de servidores"
tags: [nextjs, react, tailwindcss, typescript, github-pages, ssg]
created: 2026-11-22
updated: 2026-11-22
---

# Frontend Next.js en GitHub Pages (`dashboard`)

## 1. Arquitectura de Exportación Estática

La aplicación está construida sobre **Next.js 14+** con App Router y configurada con `output: 'export'`. Esto permite que el sitio se compile a un conjunto de ficheros HTML, JS y CSS listos para ser servidos por la infraestructura CDN de GitHub Pages sin costo.

## 2. Componentes Clave

1. **`AuthGuard.tsx`**: Componente de orden superior que intercepta la navegación. Comprueba la validez del token JWT almacenado en `sessionStorage`; si expira o no existe, redirige de inmediato a `/login`.
2. **`ServerMetrics.tsx`**: Representación gráfica y métricas en tiempo real de porcentaje de CPU por hilo, memoria RAM ocupada, swap, temperatura y latencia de red.
3. **`AiStatus.tsx`**: Monitor del motor de inferencia local. Indica el modelo activo, velocidad de procesamiento en tokens por segundo (tok/s) y latencia al primer token (TTFT).
4. **`MiningStatus.tsx`**: Panel de telemetría de XMRig con hashrate instantáneo (H/s), hilos asignados, shares validados y estado del semáforo de gobernanza de recursos.
5. **`lib/crypto.ts`**: Utilidad criptográfica cliente que calcula el resumen SHA-256 o PBKDF2 de la contraseña antes de su transmisión a la API.

## 3. Parámetros de Configuración (`next.config.mjs`)
- `basePath`: `'/xeon-nexus-sentinel'`
- `trailingSlash`: `true`
- `images`: `{ unoptimized: true }`


================================================================================
# FILE: wiki/systems/cloud-relay-api.md
================================================================================

---
type: system
title: "Cloud Relay API en Python (FastAPI)"
description: "Microservicio REST intermediario para ingesta y distribución de telemetría en nubes SaaS gratuitas"
tags: [fastapi, python, cloud-relay, koyeb, zeabur, render, jwt]
created: 2026-11-22
updated: 2026-11-22
---

# Cloud Relay API en Python (`cloud-relay`)

## 1. Propósito de la Capa de Intermediación

Debido a que el servidor HP ProLiant se encuentra tras una conexión de banda ancha residencial (NAT de doble capa o Carrier-Grade NAT sin IP pública fija) y el frontend se ejecuta como archivos estáticos en GitHub Pages, el **Cloud Relay** actúa como puente público seguro de baja latencia.

## 2. Endpoints Expuestos

| Método | Ruta | Autenticación | Función |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/telemetry` | Encabezado `X-Server-Token` | Recibe payload JSON del daemon en AlmaLinux y lo almacena en RAM circular |
| `GET` | `/api/telemetry/latest` | `Bearer <JWT_TOKEN>` | Devuelve la instantánea más reciente de métricas al frontend |
| `GET` | `/api/telemetry/history` | `Bearer <JWT_TOKEN>` | Devuelve una serie temporal con las últimas 100 muestras |
| `POST` | `/api/auth/login` | Público (Body JSON) | Valida usuario y contraseña cifrada emitiendo un JWT firmado |
| `GET` | `/api/health` | Público | Comprobación de estado para keep-alive y monitorización de uptime |

## 3. Aislamiento y Memoria Volátil

- El servicio mantiene un buffer circular `deque(maxlen=100)` en memoria volátil de Python.
- No utiliza bases de datos externas como PostgreSQL o Redis, garantizando un consumo de RAM inferior a 70 MB y adaptándose al nivel gratuito de Koyeb, Zeabur o Render.


================================================================================
# FILE: wiki/systems/almalinux-daemon.md
================================================================================

---
type: system
title: "Daemon de Telemetría en AlmaLinux 9"
description: "Servicio en segundo plano para recolección de métricas de CPU, RAM, temperatura, IA y minería en AlmaLinux 9"
tags: [almalinux, daemon, python, telemetria, systemd]
created: 2026-11-22
updated: 2026-11-22
---

# Daemon de Telemetría en AlmaLinux 9 (`xeon-sentinel`)

## 1. Responsabilidad y Funcionamiento

El daemon de telemetría reside en el servidor HP ProLiant ML150 G6 operando sobre **AlmaLinux 9 Minimal**. Su propósito es inspeccionar el estado del hardware, los procesos de inferencia local (`llama.cpp` o Ollama) y el minero XMRig (RandomX), empaquetando periódicamente un objeto JSON que se despacha vía HTTP POST al Cloud Relay.

## 2. Métricas Recolectadas

1. **CPU y Frecuencia:** Lectura diferencial de `/proc/stat` y `/proc/cpuinfo` calculando el porcentaje de uso por núcleo e integral.
2. **Memoria y NUMA:** Lectura de `/proc/meminfo` (MemTotal, MemFree, Buffers, Cached) y desglose de páginas locales vs remotas vía `numastat`.
3. **Sensores Térmicos:** Extracción mediante `sysfs` (`/sys/class/thermal/` o `coretemp`) o comando IPMI BMC.
4. **Estado de IA Local:** Sonda HTTP hacia el endpoint `/api/tags` o `/api/ps` de Ollama / `llama.cpp` server para medir modelos cargados y tiempos de generación.
5. **Estado de Criptominería:** Consulta al endpoint HTTP local de XMRig (`http://127.0.0.1:18088/1/summary`) extrayendo hashrate a 10s, 60s, 15m y temperatura de encapsulado.

## 3. Configuración y Ejecución

- **Archivo de Configuración:** `server/daemon/config.yaml`
- **Servicio Systemd:** `server/systemd/xeon-sentinel.service`
- **Cadencia de Publicación:** Cada 5 segundos en condiciones normales, con reintentos exponenciales ante fallos de red.


================================================================================
# FILE: wiki/systems/headless-pxe-netboot.md
================================================================================

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


================================================================================
# FILE: wiki/concepts/execution-timeouts-and-anti-hang-patterns.md
================================================================================

---
title: "Patrones Anti-Bloqueo y Políticas Estrictas de Timeout en Comandos del Agente"
type: "concept"
category: "resilience"
tags: ["timeout", "anti-hang", "networking", "agent-behavior", "best-practices", "devops"]
last_updated: "2026-11-22"
status: "active"
---

# Patrones Anti-Bloqueo y Políticas Estrictas de Timeout en Comandos del Agente

## 1. Análisis de Causa Raíz (Post-Mortem: Bloqueo de 39 Minutos)

Durante la preparación del entorno PXE a las 19:24 UTC, el agente emitió un comando de verificación HTTP contra el repositorio de arranque de AlmaLinux 9:
```bash
curl -I https://repo.almalinux.org/almalinux/9/os/x86_64/os/images/pxeboot/
```

### Factores Determinantes del Bloqueo:
1. **Ausencia de Parámetros de Timeout:** `curl` por defecto en Windows PowerShell no impone un límite de tiempo estricto para resolución de DNS o establecimiento de socket (`--connect-timeout` ni `--max-time`). Ante una latencia en el handshake o filtrado en el endpoint, el proceso quedó colgado indefinidamente.
2. **Delegación a Segundo Plano de Tarea Ligera:** El comando fue enviado con `WaitMsBeforeAsync: 5000` y al superar los 5 segundos pasó a tarea de segundo plano (`task-914`).
3. **Espera Reactiva Pasiva sin Guardia:** El agente finalizó el turno esperando el mensaje de notificación del sistema. Al no terminar el proceso hijo, el hilo de interacción quedó congelado por 39 minutos hasta la intervención manual del usuario.

---

## 2. Directivas Técnicas Obligatorias (Regla Anti-Hang)

Para garantizar que este comportamiento jamás se repita, se establecen las siguientes directivas de ingeniería:

### Regla 1: Timeouts Mandatorios y Acotados
Todo comando de red, consulta HTTP, sondeo de sockets o escaneo de puertos DEBE llevar parámetros de límite de tiempo explícitos:
- **En `curl`:** Siempre incluir `--connect-timeout 5 --max-time 10`.
- **En PowerShell `Invoke-WebRequest`:** Siempre pasar `-TimeoutSec 5`.
- **En sockets .NET / Python:** Configurar `ReceiveTimeout = 3000` y `socket.settimeout(3.0)`.

```powershell
# FORMA CORRECTA
curl -I --connect-timeout 5 --max-time 10 https://repo.almalinux.org/...
Invoke-WebRequest -Uri "https://..." -TimeoutSec 5 -UseBasicParsing
```

### Regla 2: Prohibición de Segundo Plano en Tareas de Diagnóstico
Los comandos de prueba de conectividad, verificación de URLs, comprobaciones de estado y sondeos de adaptadores son operaciones que **deben resolverse sincrónicamente en menos de 5 a 8 segundos**.
- Si un comando de diagnóstico no responde en 5 segundos, debe ser cancelado inmediatamente y el agente debe reportar el resultado (endpoint inalcanzable o timeout) sin ceder el control a una espera pasiva.

### Regla 3: Tareas de Fondo Exclusivas para Cargas Pesadas
Solo las transferencias de datos masivas (como respaldos de gigabytes con `rclone` o compilaciones de software extensas) tienen permitido ejecutarse en segundo plano, e incluso estas deben incluir telemetría periódica (`--stats 10s`) y un informe inmediato al usuario sin bloquear la conversación.


================================================================================
# FILE: wiki/concepts/server-memory-and-bios-governance.md
================================================================================

---
type: concept
title: "Gobernanza de Memoria RAM, Arquitectura RDIMM/UDIMM y Configuración de Arranque en HP ProLiant ML150 G6"
description: "Estándares de memoria DDR3 ECC, incompatibilidad entre RDIMM y UDIMM, configuración de BIOS AMI v02.61 y arranque con Smart Array P410"
tags: [rdimm, udimm, ecc, hp-proliant, smart-array, bios, matrox-g200, memory-rules]
created: 2026-11-26
updated: 2026-11-26
---

# Gobernanza de Memoria RAM, Arquitectura RDIMM/UDIMM y Configuración de Arranque en HP ProLiant ML150 G6

Este documento compendia las reglas de arquitectura de hardware, directivas de población de memoria RAM DDR3 ECC y procedimientos de configuración de arranque (BIOS y Option ROM de controladora RAID) para el nodo servidor HP ProLiant ML150 G6 con procesadores Intel Xeon serie 5500 (Nehalem-EP).

---

## 1. Arquitectura de Memoria del Servidor (Intel Nehalem-EP / Xeon 5500)

El procesador Intel Xeon E5504 integra su propio controlador de memoria (IMC - Integrated Memory Controller) con arquitectura de **Triple Canal (Triple-Channel)** DDR3 a 800/1066/1333 MHz.

### Comparativa Tecnológica: RDIMM vs UDIMM

| Parámetro | RDIMM (Registered DIMM / terminación "R") | UDIMM (Unbuffered DIMM / terminación "E") |
| :--- | :--- | :--- |
| **Identificador Estándar** | `PC3-10600R`, `PC3-8500R` | `PC3-10600E`, `PC3-8500E` |
| **Componente Clave** | Chip de registro de hardware (RCD - Registering Clock Driver) que amortigua señales de comando y dirección. | Conexión eléctrica directa entre las líneas del bus del IMC y cada chip DRAM. |
| **Carga Eléctrica en CPU** | Muy baja; el procesador solo maneja la carga del registro, no de los chips individuales. | Elevada; la capacitancia y carga eléctrica se multiplican por cada chip DRAM insertado. |
| **Capacidad Máxima (ML150 G6)** | Hasta **48 GB** (Xeon 5500) o hasta **96 GB / 192 GB** (Xeon 5600) poblando los 12 zócalos. | Limitada a un máximo de **24 GB** en todo el servidor (máximo 2 zócalos por canal). |
| **Estabilidad y Tolerancia 24/7** | Misión crítica empresarial, reduce jitter y ruido eléctrico en el bus. | Estaciones de trabajo de entrada o microservidores de bajo consumo. |
| **Paradoja de Precios de Mercado** | **Extremadamente económicas** en reventa (surplus de datacenters; no sirven en PCs comunes). | **Más costosas** (alta demanda por usuarios que reviven placas de escritorio y estaciones Z). |

---

## 2. Incompatibilidad Absoluta y Regla de Coexistencia de Memoria

> [!CAUTION]
> **REGLA ABSOLUTA DE HARDWARE (HP QuickSpecs & Intel Memory Reference Code):**
> **ESTÁ TERMINANTEMENTE PROHIBIDO MEZCLAR MÓDULOS RDIMM CON UDIMM EN EL MISMO SISTEMA.**
> 
> 1. **Incompatibilidad a Nivel de Placa y Sistema:** La prohibición aplica no solo al mismo canal, sino a **toda la placa base**. 
> 2. **Comportamiento en Dual Socket:** Si se instala un segundo procesador Xeon (CPU2), **NO es posible** colocar RDIMM en el CPU1 y UDIMM en el CPU2. El bus QPI (QuickPath Interconnect) y la inicialización de la BIOS exigen un único modo de temporización y búfer homogéneo.
> 3. **Consecuencia de la Mezcla:** El código MRC (Memory Reference Code) de la BIOS se detiene en POST Fase 1, emite pitidos de error de memoria y bloquea la salida de vídeo (pantalla negra permanente).

---

## 3. Inventario de Módulos del Nodo y Diagnóstico de Adquisición

### A. Módulos Adquiridos (Tecnología Correcta)
* **Modelo:** Micron 4 GB `PC3-10600R` (`MT36JBZS51272PY-1G4D1`).
* **Especificación:** DDR3-1333 Registered ECC con paridad, diseño de bajo perfil.
* **Cantidad:** 2 módulos (8 GB totales).
* **Veredicto:** Son las memorias óptimas de grado servidor. Estandarizan el equipo en arquitectura RDIMM.

### B. Módulos Preexistentes (Heredados del Propietario Anterior)
* **Módulos Azules:** 2 × Nanya 4 GB 2Rx8 `PC3-10600E-9-10-E0` (HP P/N: `500210-071` / Kit `500672-B21`).
* **Módulo Verde:** 1 × Samsung 2 GB 2Rx8 `PC3-10600E-09-10-E1` (HP Spare: `501533-001` / Kit `500670-B21`).
* **Tipo:** UDIMM Unbuffered ECC.
* **Veredicto:** Piezas originales HP de catálogo que funcionaban solas sumando 10 GB, pero incompatibles con cualquier ampliación RDIMM.

### C. Directiva de Expansión Futura
Para ampliar la memoria del servidor a 16 GB, 24 GB o 48 GB:
* Adquirir exclusivamente módulos **RDIMM** (`PC3-10600R` o `PC3-8500R`) de 4 GB u 8 GB (ej. Micron, Samsung o Hynix de servidor).
* Descartar cualquier compra de módulos terminados en "E" (`10600E`).

---

## 4. Parámetros de BIOS AMI v02.61 para Arranque Fiable

Para evitar falsos bloqueos o fallos de arranque con la controladora **HP Smart Array P410** y discos SAS de 15,000 RPM:

| Parámetro en BIOS Setup | Valor Recomendado | Justificación Operativa |
| :--- | :--- | :--- |
| **`Quick Boot`** | **`[Disabled]`** | **Crítico:** Evita que la BIOS salte al bootloader antes de que la controladora Smart Array P410 termine de acelerar (spin-up) los discos SAS y registrar el volumen lógico. |
| **`Quiet Boot`** | **`[Disabled]`** | Elimina el logo gráfico estático de HP y muestra en consola cruda todos los mensajes del POST, códigos de error y saltos de GRUB. |
| **`1st Boot Device`** | **`[Hard Drive]`** | Destina el arranque al subsistema de almacenamiento principal. |
| **`2nd Boot Device`** | **`[Disabled]`** | Previene re-arranques accidentales hacia Windows o interfaces de red cuando se desea operar localmente. |
| **Submenú `Hard Disk Drives`** | **`1st Drive: [RAID:Smart Array P]`** | Designa la Option ROM de la controladora P410 como disco duro primario (BBS Priority). |

---

## 5. Configuración de Boot Volume en Option ROM de Smart Array P410

Si la BIOS no encuentra el sector de arranque de AlmaLinux 9 en `/dev/sda`:
1. Durante el POST, observar la inicialización de la controladora:
   ```text
   HP Smart Array P410 Controller (256MB, vX.XX)
   1 Logical Drive
   Press <F8> to configure
   ```
2. Pulsar **`F8`** para ingresar a la utilidad ACU (Array Configuration Utility) embebida en ROM.
3. Ingresar a **`Select Boot Volume`**.
4. Marcar explícitamente el **`Logical Drive 1`** (419 GB SAS RAID) como disco de arranque primario.
5. Guardar con **`F8`** y reiniciar.

---

## 6. Diagnóstico de Pantalla "Sin Señal" (Matrox G200e + Conversor VGA-HDMI)

La aparición recurrente del mensaje *"Sin señal"* en el monitor o televisor HDMI responde a dos factores físicos:
1. **Pausa por Detección de Cambio de RAM:** Tras retirar módulos y variar la capacidad (de 10 GB a 8 GB), la BIOS detiene el arranque con el mensaje `Memory size has changed. Press F1 to continue`. Si el monitor aún no sincroniza, la máquina parece apagada pero está esperando la tecla `F1`.
2. **Desincronización de Reloj en el Conversor VGA-HDMI:** El chip gráfico integrado **Matrox G200e** altera su frecuencia analógica al pasar del modo texto BIOS (720×400 @ 70Hz) al framebuffer del kernel Linux (`mgag200`). Los convertidores pasivos o activos de bajo costo pierden el enganche de fase y el monitor se apaga.
   * **Mitigación:** Esperar 60-90 segundos a que concluya el arranque del sistema operativo y acceder remotamente por red (SSH / Cockpit) o reconectar el cable de alimentación auxiliar USB del conversor.


================================================================================
# FILE: wiki/concepts/randomx-cache-isolation.md
================================================================================

---
type: concept
title: "Aislamiento de Recursos y Caché L3 en Minería RandomX"
description: "Fórmula de dimensionamiento de hilos para RandomX basada en 2 MB de caché L3 y gobernanza contra la inferencia de IA"
tags: [randomx, xmrig, cache-l3, numa, mineria, cpu, xeon]
created: 2026-11-22
updated: 2026-11-22
---

# Aislamiento de Recursos y Caché L3 en Minería RandomX

## 1. La Regla de Oro de RandomX (2 MB L3 por Hilo)

El algoritmo RandomX utilizado por Monero está diseñado para resistir ASICs mediante el uso intensivo de la memoria caché de nivel 3 (L3 Cache) y accesos de memoria aleatorios con alta sensibilidad a la latencia.

Cada hilo de minería en RandomX requiere estrictamente **2 MB de memoria caché L3**.

### Cálculo de Hilos Máximos

Para dimensionar los hilos de XMRig sin saturar el procesador:

`Hilos Máximos = Piso(Caché L3 Total en MB / 2)`

Por ejemplo:
- Intel Xeon E5520 (8 MB Caché L3): Hilos Máximos = 8 / 2 = 4 hilos.
- Intel Xeon X5670 (12 MB Caché L3): Hilos Máximos = 12 / 2 = 6 hilos.

Si se configuran más hilos de los permitidos por la caché física, los hilos excedentes deben acceder a la memoria RAM DDR3 para buscar los datos de Scratchpad, multiplicando la latencia por un factor de 10× y provocando una caída catastrófica del hashrate global.

## 2. Competencia de Memoria: IA vs Minería

Tanto la inferencia de modelos de lenguaje en CPU como la minería RandomX saturan por completo los canales de memoria del bus IMC. Ejecutar ambas tareas en paralelo degrada el rendimiento de la IA a menos de 1 token por segundo y reduce el hashrate en más del 70%.

### Algoritmo del Gobernador (`ai-miner-governor.sh`)

1. El script vigila la presencia de peticiones de inferencia activas en el puerto de Ollama / `llama.cpp`.
2. Al detectar inferencia en curso:
   - Envía comando HTTP `POST /1/pause` al minero XMRig.
   - Libera el 100% del ancho de banda del bus de memoria y núcleos para el modelo de IA.
3. Al concluir la generación del texto:
   - Envía comando HTTP `POST /1/resume` al minero.
   - Restablece la minería de fondo.


================================================================================
# FILE: wiki/concepts/cpu-inference-tuning.md
================================================================================

---
type: concept
title: "Afinamiento de Inferencia de IA en CPU Xeon Legada"
description: "Estrategias de cuantización y compilación para inferencia de LLM en procesadores Intel Xeon sin soporte AVX2"
tags: [ia, llm, llama-cpp, cuantizacion, sse4-2, xeon, cpu]
created: 2026-11-22
updated: 2026-11-22
---

# Afinamiento de Inferencia de IA en CPU Xeon Legada

## 1. Desafío Arquitectónico: Ausencia de AVX2

Los procesadores Intel Xeon de la generación Nehalem y Westmere (LGA1366) carecen de los conjuntos de instrucciones vectoriales AVX y AVX2. Su límite vectorial se encuentra en **SSE4.2**. La mayoría de binarios precompilados modernos de PyTorch, TensorFlow o `llama.cpp` fallan con error de instrucción ilegal (`Illegal instruction (core dumped)`) si se ejecutan directamente.

## 2. Soluciones y Reglas de Optimización

1. **Compilación Nativa de `llama.cpp`:**
   - La herramienta debe compilarse desde el código fuente desactivando AVX y activando SSE4.2:
     `cmake -B build -DLLAMA_AVX=OFF -DLLAMA_AVX2=OFF -DLLAMA_FMA=OFF -DLLAMA_F16C=OFF`
2. **Selección de Modelos Cuantizados:**
   - Para CPUs con ancho de banda de memoria limitado (DDR3 ECC), los modelos óptimos son de 1B a 3B parámetros con cuantización agresiva `Q4_K_M` o `Q3_K_M`.
   - Ejemplos recomendados: Llama-3.2-1B-Instruct, Qwen2.5-0.5B / 1.5B, SmolLM2-1.7B.
3. **Mapeo en Memoria y Bloqueo de Paginación:**
   - Se debe utilizar la bandera `--mlock` para impedir que el sistema operativo mueva los pesos del modelo al espacio de intercambio (swap) en disco.
4. **Asignación de Hilos:**
   - El número de hilos de cómputo (`-t`) debe coincidir exactamente con el número de núcleos físicos del socket asignado (excluyendo Hyper-Threading para evitar contención de caché L1/L2).


================================================================================
# FILE: wiki/concepts/storage-optimization-and-gdrive-backup.md
================================================================================

---
title: "Optimización de Almacenamiento Local y Respaldo en Google Drive con Rclone"
type: "concept"
category: "storage"
tags: ["storage", "rclone", "gdrive", "backup", "windows11", "wsl", "disk-cleanup"]
last_updated: "2026-11-22"
status: "active"
---

# Optimización de Almacenamiento Local y Respaldo en Google Drive con Rclone

## 1. Visión General

El entorno de desarrollo y operación de **Xeon Nexus Sentinel** requiere balancear el espacio en disco de la estación de control (Laptop Windows 11 con WSL2) con las necesidades de compilación, modelos locales de IA y telemetría.

Para evitar saturación de la partición de sistema `C:`, se implementó una estrategia híbrida de dos niveles:
1. **Limpieza interna periódica sin privilegios de administrador:** Eliminación de cachés de npm, pip, NuGet, temporales de usuario y artefactos de desarrollo (`node_modules` inactivos, `.next/cache`).
2. **Respaldo y liberación de espacio en nube con `rclone`:** Conexión directa a Google Drive (cuenta de 5 TiB con 4.899 TiB disponibles) mediante binario portable en espacio de usuario (`C:\Users\lenin\rclone\rclone.exe`) y script de orquestación `scripts/gdrive-backup.ps1`.

---

## 2. Métricas de Capacidad Verificadas

- **Capacidad Total en Google Drive:** 5 TiB
- **Espacio Libre en Nube:** 4.899 TiB
- **Espacio Utilizado Actual:** 19.038 GiB
- **Espacio Recuperado en Windows C:** +19.91 GB (de 8.94 GB a 28.85 GB libres)
- **Espacio Reclamado en WSL2:** +33 GB (de 85 GB a 52 GB usados)

---

## 3. Automatización: `scripts/gdrive-backup.ps1`

El script implementa tres operaciones principales con validación de integridad previa al borrado:

| Acción | Modo Rclone | Comportamiento | Casos de Uso Recomendados |
| :--- | :--- | :--- | :--- |
| `Copy` | `rclone copy` | Duplica los archivos locales en la nube sin alterar el origen. | Respaldos preventivos de código, configuraciones y modelos. |
| `Move` | `rclone move` | Transfiere a la nube y **elimina localmente sólo tras verificación SHA-1**. | Liberación de espacio en carpetas de Descargas, renders o videos. |
| `Sync` | `rclone sync` | Mantiene el destino exactamente idéntico al origen. | Espejado unidireccional de directorios de trabajo. |

### Parámetros Principales
- `-SourcePath`: Ruta local de origen (ej: `C:\Users\lenin\Documents`).
- `-RemotePath`: Directorio remoto en Google Drive (ej: `gdrive:Backup/Documents`).
- `-BeforeDate`: Fecha de corte temporal (por defecto: `'2026-01-01'`).
- `-CheckLastAccess`: Validación dual estricta. Exige que el archivo no haya sido modificado ni abierto/leído (`LastAccessTime`) después de la fecha de corte. Protege archivos antiguos que se siguen utilizando activamente (como canciones o documentos de consulta frecuente).
- `-MinAgeDays`: Filtra únicamente archivos con más de N días de antigüedad (ej: `-MinAgeDays 60`).
- `-DryRun`: Switch de simulación que lista las acciones sin realizar ningún cambio ni borrado.

---

## 4. Regla de Inactividad Real (LastWriteTime vs LastAccessTime)

En Windows 11 NTFS, la actualización de último acceso se encuentra habilitada (`DisableLastAccess = 2`). Una auditoría sobre 170,495 archivos reveló que 40,842 archivos modificados antes de 2026 (23.77 GB) fueron abiertos y utilizados durante 2026.
Para evitar archivar o borrar archivos de consulta activa (como la música o referencias cotidianas), el sistema requiere la evaluación conjunta:
`LastWriteTime < FechaCorte Y LastAccessTime < FechaCorte`.

---

## 4. Ejemplos de Uso en PowerShell

### Simulación preventiva (Dry-Run)
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\gdrive-backup.ps1 -SourcePath "C:\Users\lenin\Downloads" -MinAgeDays 60 -Action Move -DryRun
```

### Liberación real de espacio para archivos con más de 60 días
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\gdrive-backup.ps1 -SourcePath "C:\Users\lenin\Downloads" -MinAgeDays 60 -Action Move
```

### Respaldo de proyectos o documentos sin borrar localmente
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\gdrive-backup.ps1 -SourcePath "C:\Users\lenin\Documents" -Action Copy
```


================================================================================
# FILE: wiki/concepts/secrets-management-and-gitguardian.md
================================================================================

---
type: concept
title: "Gestión Segura de Credenciales y Validación con GitGuardian"
description: "Estrategias de protección de secretos, aislamiento de contraseñas en hosting estático y uso del nivel gratuito de GitGuardian"
tags: [seguridad, secretos, gitguardian, ggshield, devsecops, jwt]
created: 2026-11-22
updated: 2026-11-22
---

# Gestión Segura de Credenciales y Validación con GitGuardian

## 1. ¿Por Qué las Credenciales NO Quedan Expuestas en GitHub?

### A. Capa Frontend (GitHub Pages)
- El panel de control se compila a JavaScript estático (`output: 'export'`).
- El código en GitHub Pages **no almacena ni incluye la contraseña del administrador**.
- Cuando el usuario ingresa sus datos en `/login/`:
  1. El navegador utiliza la Web Crypto API (`crypto.subtle.digest`) para calcular el hash SHA-256 de la contraseña en la memoria volátil del navegador.
  2. El frontend despacha una petición `POST /api/auth/login` con el usuario y el hash al Cloud Relay.
  3. Ni la contraseña en claro ni las credenciales maestras quedan en el árbol de Git ni en los archivos HTML/JS estáticos.

### B. Capa de Servicios (Cloud Relay en Koyeb / Zeabur / Render)
- El microservicio en Python lee las credenciales exclusivamente desde **variables de entorno del sistema operativo del contenedor**:
  - `ADMIN_USER`
  - `ADMIN_PASSWORD_HASH`
  - `JWT_SECRET_KEY`
  - `SERVER_INGEST_TOKEN`
- Estas variables se definen directamente en la consola web del proveedor cloud (fuera del repositorio) y `.gitignore` bloquea cualquier archivo `.env` o token local.

---

## 2. Implementación Gratuita de GitGuardian

GitGuardian ofrece un plan gratuito permanente (Free Tier) para desarrolladores individuales y proyectos personales (hasta 25 desarrolladores):

### Opción A: GitGuardian GitHub App (Monitoreo en la Nube)
1. Instalar la aplicación gratuita **GitGuardian** desde el GitHub Marketplace:
   `https://github.com/marketplace/gitguardian`
2. Seleccionar el repositorio `merolhack/xeon-nexus-sentinel`.
3. Cada vez que se realiza un `git push` o un Pull Request, los servidores de GitGuardian escanean automáticamente todos los commits. Si se detecta un token o clave privada, el desarrollador recibe una notificación de incidente inmediata.

### Opción B: CLI `ggshield` Local (Shift-Left DevSecOps)
Permite bloquear la creación del commit en la propia máquina antes de que los datos salgan hacia internet:
1. Instalar `ggshield` en el entorno WSL o Windows:
   ```bash
   pip install ggshield
   ```
2. Iniciar sesión con la cuenta gratuita:
   ```bash
   ggshield auth login
   ```
3. Activar el hook pre-commit:
   ```bash
   ggshield install -m repo
   ```
   A partir de ese momento, `ggshield secret scan pre-commit` se ejecutará en cada `git commit`.

### Opción C: Escaneo Nativo Integrado en el Repositorio (`scripts/scan-secrets.sh`)
Para operar de inmediato sin depender de cuentas externas:
- El repositorio incluye [scripts/scan-secrets.sh](file:///wsl.localhost/ubuntu-20.04/home/merolhack/fl/xeon-nexus-sentinel/scripts/scan-secrets.sh) y [.githooks/pre-commit](file:///wsl.localhost/ubuntu-20.04/home/merolhack/fl/xeon-nexus-sentinel/.githooks/pre-commit).
- Verifica mediante expresiones regulares que ningún cambio preparado contenga tokens de GitHub (`ghp_`), AWS (`AKIA...`), claves privadas SSH/RSA (`BEGIN PRIVATE KEY`) o tokens JWT.
- Activar los hooks compartidos con:
  ```bash
  git config core.hooksPath .githooks
  ```


================================================================================
# FILE: wiki/concepts/static-client-auth.md
================================================================================

---
type: concept
title: "Autenticación Criptográfica para Clientes Estáticos"
description: "Esquema de autenticación sin backend dinámico en hosting estático mediante Web Crypto API y tokens JWT"
tags: [seguridad, web-crypto-api, jwt, static-auth, sha256]
created: 2026-11-22
updated: 2026-11-22
---

# Autenticación Criptográfica para Clientes Estáticos

## 1. El Reto del Hosting Estático en GitHub Pages

GitHub Pages distribuye contenido exclusivamente estático (HTML, CSS y JS compilados). No existe un servidor Node.js o PHP intermedio para gestionar sesiones con cookies seguras `HttpOnly` originadas en el mismo dominio.

## 2. Flujo de Autenticación Criptográfica

Para permitir la visualización privada de métricas:

1. **Ingreso en el Cliente:** El usuario introduce su nombre de usuario y contraseña en la página `/login/`.
2. **Pre-hashing con Web Crypto API:** El navegador calcula un hash SHA-256 de la contraseña utilizando la API nativa `crypto.subtle.digest`. Nunca se transmite la contraseña en texto plano en la red.
3. **Petición al Cloud Relay:** El frontend envía las credenciales hasheadas a la ruta `POST /api/auth/login` del microservicio FastAPI en la nube.
4. **Validación Segura:** La API compara el usuario y el hash con las variables de entorno `ADMIN_USER` y `ADMIN_PASSWORD_HASH` mediante comparación en tiempo constante (`hmac.compare_digest`) para prevenir ataques de temporización.
5. **Emisión de Token JWT:** Si la validación es correcta, la API emite un token JWT firmado con algoritmo HS256 y un tiempo de expiración (ej. 24 horas).
6. **Almacenamiento en `sessionStorage`:** El frontend guarda el token únicamente en la memoria de la pestaña del navegador (`sessionStorage`), reduciendo el riesgo de persistencia indebida.
7. **Guardia de Navegación (`AuthGuard`):** Las rutas protegidas validan la presencia y vigencia del token antes de renderizar los gráficos de telemetría.


================================================================================
# FILE: wiki/concepts/strata-vs-ollama-inference.md
================================================================================

# Strata vs Ollama: Análisis Arquitectónico e Inferencia MoE en Hardware Restringido

## 1. Visión General de Strata
**Strata** (`Niko1221/Strata` y bifurcaciones como `Strata-GLM`) es un motor de inferencia de alto rendimiento desarrollado en **C++20** sobre el ecosistema `llama.cpp` y `ggml`. Prescinde por completo del intérprete de Python, PyTorch o TensorFlow en la ruta de inferencia, eliminando la contención por el GIL (*Global Interpreter Lock*) y la fragmentación de memoria.

Su propósito fundamental es la ejecución eficiente de modelos masivos de arquitectura **Mixture-of-Experts (MoE)** —tales como **Qwen3.8-Flash-Next** (125B parámetros totales, 24,576 expertos, 10 activos / ~6B efectivos por token) o **GLM-5.3-Flash** (320B)— en hardware accesible.

```text
               ┌────────────────────────────────────────────────────────┐
               │             Jerarquía de Memoria de Strata             │
               └────────────────────────────────────────────────────────┘
                                           │
         ┌─────────────────────────────────┼─────────────────────────────────┐
         ▼                                 ▼                                 ▼
   [Tier 1: VRAM GPU]             [Tier 2: Host RAM Arena]          [Tier 3: NVMe Page Cache]
   - Capas compartidas            - Espacio anclado (mlock)         - Tabla n-gram 28.8 GB
   - Atención y router            - Todos los expertos enrutados    - Búsqueda no matricial
   - Caché de expertos activos    - Cómputo CPU paralelo (SIMD)     - Mapeo directo de páginas
```

---

## 2. Ventajas Arquitectónicas frente a Ollama / llama.cpp Tradicional

| Característica | **Strata** | **Ollama / llama.cpp** |
| :--- | :--- | :--- |
| **Enfoque de Diseño** | Ultra-especializado en MoE dispersos gigantes (125B a 320B). | Motor generalista para decenas de arquitecturas densas (1B a 70B). |
| **Gestión de Expertos** | Caché dinámico en VRAM + arena de RAM fija + ejecución paralela GPU/CPU. | Carga estática de capas en GPU/RAM o descarga completa secuencial. |
| **Aceleración Algorítmica** | Multi-Token Prediction (MTP) especulativo (1.6x a 1.8x), Prompt Lookup Cache y Chunked Prefill. | Autoregresión estándar token por token; soporte MTP limitado o manual. |
| **Cuantización Avanzada** | Cuantización GSQ-RCO (IQ2_XS, IQ3_S) garantizando 4 bits mínimos en caches. | Cuantizaciones k-quants tradicionales (Q4_K_M, Q5_K_M, Q8_0). |
| **Throughput Reportado** | 60 a 140+ tokens/segundo en GPUs de consumo (RTX 3090/4090/5070 con 64 GB RAM). | 15 a 35 tokens/segundo en arquitecturas MoE comparables. |
| **APIs Expuestas** | Endpoints nativos compatibles con OpenAI, Anthropic Messages y servidor MCP integrado. | API nativa de Ollama y emulación OpenAI. |

---

## 3. Viabilidad y Requerimientos en el HP ProLiant ML150 G6

El análisis de compatibilidad frente a las especificaciones del nodo servidor revela cuatro condiciones determinantes:

1. **Conjunto de Instrucciones del Procesador (SSE4.2 vs AVX2/AVX-512):**
   * Strata compila sus kernels de CPU para AVX-512 y AVX2.
   * El procesador **Intel Xeon E5504 (Nehalem LGA1366)** carece de AVX y AVX2, limitándose a **SSE4.2**.
   * Los binarios precompilados arrojan de inmediato `Illegal instruction (core dumped)`. Requeriría compilación manual con banderas `-DLLAMA_AVX=OFF -DLLAMA_AVX2=OFF`.
2. **Capacidad de Memoria Física (8 GB actuales vs 32–64 GB mínimos):**
   * Strata exige anclar (`mlock`) todos los pesos de los expertos en memoria física, rechazando el mapeo perezoso bajo demanda.
   * Modelos MoE comprimidos requieren un mínimo absoluto de 32 GB a 64 GB de RAM. En 8 GB de RAM, la ejecución falla por agotamiento de memoria (**OOM Killer**).
3. **Almacenamiento (Discos SAS 15K RPM vs NVMe):**
   * El desacople de la tabla n-gram (28.8 GB) asume lecturas aleatorias ultrarrápidas sobre bus PCIe/NVMe. En discos rotacionales SAS, los tiempos de búsqueda mecánica degradan la latencia.
4. **Ausencia de GPU Dedicada:**
   * Sin acelerador gráfico con VRAM para alojar la atención y el router, todo el flujo recae en el bus QPI de memoria DDR3 de 800 MHz.

---

## 4. Estrategia Híbrida Recomendada para Xeon Nexus Sentinel

* **En el Servidor HP ProLiant (Bare-Metal Headless):**
  * Mantener **`llama.cpp` nativo optimizado para SSE4.2** (o Ollama ligero).
  * Desplegar modelos densos de 1B a 3B (**Llama-3.2-1B-Instruct**, **Qwen2.5-1.5B** en cuantización `Q4_K_M`) que ocupan entre 1.1 GB y 2.2 GB de RAM, permitiendo inferencias locales rápidas de 12 a 18 tokens/s y dejando libres 5 GB de RAM para el daemon y HugePages de RandomX.
* **Evolución Futura para Habilitar Strata:**
  1. Instalar los 3 módulos RAM restantes y ampliar el servidor a 48 GB DDR3 ECC (máximo por CPU).
  2. Incorporar una tarjeta gráfica PCIe de consumo (ej. NVIDIA RTX 3060 12GB o superior) con alimentación adaptada.
  3. Desplegar Strata mediante su contenedor Docker oficial para servir APIs OpenAI/Anthropic hacia la red interna.


================================================================================
# FILE: wiki/raw/prompt-inicializacion-sistema-monitoreo-xeon.md
================================================================================

# Especificación de Arquitectura y Prompt de Inicialización: Ecosistema Híbrido Xeon-Nexus (IA, Criptominería y Telemetría Headless)

## 1. Identificación y Metadatos del Repositorio en GitHub

El proyecto se estructurará como un repositorio público centralizado bajo el perfil de GitHub del desarrollador `merolhack`. Este repositorio albergará la totalidad de la infraestructura de código: el frontend estático de visualización, la API REST de intermediación en la nube, los servicios de recolección de métricas para el servidor y la memoria estructurada del sistema para agentes de inteligencia artificial.

### Ficha Técnica del Repositorio

*   **Cuenta de GitHub**: `merolhack`
*   **Nombre del Repositorio**: `xeon-nexus-sentinel` (Alternativa sugerida: `xeon-mesh-monitor`)
*   **Visibilidad**: Pública (`Public`)
*   **Descripción del Repositorio**:
    > Panel de control Next.js en GitHub Pages para monitoreo y administración de un servidor HP ProLiant Xeon con AlmaLinux en modo headless, inferencia de IA local (Ollama/llama.cpp), criptominería CPU y microservicios REST en Python sobre plataformas SaaS gratuitas, con memoria de proyecto compilada bajo el estándar Google OKF v0.2 y el patrón Karpathy LLM Wiki.
*   **Temas Principales (GitHub Topics)**:
    `nextjs`, `github-pages`, `almalinux`, `intel-xeon`, `ollama`, `open-knowledge-format`, `llm-wiki`, `antigravity-ide`, `headless-server`, `cryptomining`, `fastapi`, `zero-cost-infrastructure`, `cockpit-linux`.
*   **Licencia del Proyecto**: MIT License.

---

## 2. Arquitectura General y Matriz de Integración del Stack

El ecosistema integra infraestructura física on-premises (servidor empresarial legado y estación de trabajo portátil Windows 11), modelos de lenguaje locales distribuidos, servicios en la nube sin costo financiero y un frontend web estático desplegado en GitHub Pages.

### Flujo de Datos y Conectividad entre Componentes

1.  **Capa de Presentación (GitHub Pages)**: Aloja la aplicación Next.js compilada como sitio puramente estático (`output: 'export'`). Presenta el panel de control con métricas en tiempo real y requiere autenticación mediante usuario y contraseña antes de desbloquear la interfaz.
2.  **Capa de Intermediación (SaaS Gratuito en la Nube)**: Un microservicio ligero en Python (desplegado en Koyeb, Zeabur o Render) actúa como API Gateway público seguro. Recibe las actualizaciones de telemetría emitidas desde la red local mediante peticiones HTTP autenticadas y las sirve bajo demanda al frontend de GitHub Pages.
3.  **Capa de Cómputo Local (Red Doméstica Privada)**:
    *   **Laptop Windows 11**: Funciona como entorno de desarrollo con Antigravity IDE, ejecuta modelos de lenguaje locales mediante Ollama y proporciona la consola de entrada/salida (teclado y pantalla) para interactuar con el servidor.
    *   **Servidor HP ProLiant ML150 G6**: Equipado con procesador Intel Xeon y AlmaLinux 9 Minimal (sin interfaz gráfica). Ejecuta tareas de cómputo en segundo plano: inferencia cuantizada con `llama.cpp`, minería de criptomonedas (RandomX) con aislamiento de recursos y recolección continua de telemetría de hardware.

### Matriz de Responsabilidades por Componente

La siguiente matriz detalla la distribución de funciones, las tecnologías de soporte y el entorno operativo asignado a cada componente del sistema:

| Componente | Plataforma / Entorno | Rol en el Ecosistema | Tecnologías y Protocolos |
| :--- | :--- | :--- | :--- |
| **Frontend Dashboard** | GitHub Pages (`merolhack.github.io`) | Visualización de telemetría, gráficas de rendimiento y consola de estado | Next.js 14+ (SSG), Tailwind CSS, TypeScript, Web Crypto API |
| **Cloud Relay API** | Koyeb / Zeabur / Render (Free Tier) | Ingestión de telemetría, almacenamiento en memoria y autenticación | Python 3.12, FastAPI, Uvicorn, JSON Web Tokens (JWT) |
| **Servidor Cómputo** | HP ProLiant ML150 G6 (Xeon) | Inferencia LLM en CPU, minería Monero/RandomX y telemetría de bajo nivel | AlmaLinux 9 Minimal, OpenSSH, Cockpit (puerto 9090), `llama.cpp`, XMRig, `numastat`, `turbostat` |
| **Nodo Workstation** | Laptop Windows 11 | Desarrollo agéntico, modelos locales y consola remota | Antigravity IDE, Ollama, PowerShell 7, OpenSSH Client, navegador web |
| **Memoria de Código** | Repositorio Git (`merolhack`) | Base de conocimiento compilada para navegación y consistencia del agente | Google OKF v0.2, Karpathy LLM Wiki (`raw/`, `wiki/`, `index.md`, `log.md`, `AGENTS.md`) |

---

## 3. Topología Física y Operación Headless sin Teclado ni Monitor Físicos

El servidor HP ProLiant carece de periféricos de entrada y salida propios. La administración se centraliza utilizando la pantalla y el teclado de la laptop con Windows 11 a través de mecanismos de red y gestión fuera de banda.

### 3.1. Esquema de Conexión de Red

La comunicación física entre los equipos a corta distancia (menos de 2 metros) se establece mediante dos opciones estructuradas:

*   **Enlace mediante Repetidor WiFi (Topología Recomendada)**:
    *   El repetidor WiFi se conecta de manera inalámbrica al router principal del hogar y expone dos puertos Ethernet RJ-45 independientes.
    *   El puerto Ethernet 1 se conecta a la tarjeta de red principal del servidor HP ProLiant para el tráfico general del sistema operativo AlmaLinux 9.
    *   El puerto Ethernet 2 se conecta al puerto de gestión remota **HP iLO 100i (BMC)** del servidor.
    *   La laptop Windows 11 se conecta por WiFi al repetidor en el mismo segmento de red local, obteniendo acceso transparente a la consola iLO, a la sesión SSH y a la salida hacia internet.
*   **Enlace Directo Alternativo por Cable de Red**:
    *   Si se opta por un cable Ethernet directo entre la laptop y el servidor, las tarjetas de red Gigabit modernas ejecutan la conmutación de señales automáticamente mediante Auto-MDIX (eliminando la necesidad de un cable cruzado tradicional).
    *   Se define una subred privada estática (por ejemplo, Laptop en `192.168.50.1` y Servidor en `192.168.50.2`), y Windows 11 comparte su conexión WiFi hacia el adaptador Ethernet mediante Internet Connection Sharing (ICS), asignando DHCP y salida web al servidor.

### 3.2. Estrategia de Consola: Teclado y Pantalla Virtuales

La ausencia de periféricos dedicados se resuelve mediante la siguiente jerarquía de acceso:

*   **Gestión Fuera de Banda (HP iLO 100i)**:
    *   El controlador BMC integrado en el servidor se mantiene energizado con la corriente de reserva del chasis (*standby power*), incluso con la máquina apagada.
    *   Permite controlar el encendido, apagado forzado o reinicio, y monitorear la salud de sensores de temperatura y ventiladores directamente desde el navegador web en Windows 11 ingresando a la IP del puerto iLO.
*   **Consola en Banda (OpenSSH y Cockpit)**:
    *   **OpenSSH**: Acceso nativo por terminal desde Windows Terminal o PowerShell (`ssh -i ~/.ssh/id_ed25519 admin@IP_SERVIDOR`). El teclado físico de la laptop actúa directamente como consola del servidor sin latencia perceptible.
    *   **Cockpit (Puerto 9090)**: Servicio web nativo de AlmaLinux que no instala entorno gráfico pesado en el servidor. Proyecta en el navegador de la laptop una terminal interactiva completa, gestión de almacenamiento, monitor de servicios `systemd` y métricas de rendimiento en tiempo real.
*   **Diagnóstico Físico Inicial (Convertidor Activo VGA a HDMI)**:
    *   Para visualizar el arranque inicial del BIOS (POST) o verificar la configuración de red inicial, se conecta un convertidor activo de VGA macho a HDMI hembra (con alimentación USB a 5V desde el propio chasis del servidor), proyectando la imagen analógica en un monitor externo estándar con entrada HDMI.

---

## 4. Estructura de Memoria del Codebase: Google OKF v0.2 + Karpathy LLM Wiki

Para que el entorno de desarrollo agéntico **Antigravity IDE** mantenga una comprensión profunda del código y tome decisiones consistentes a través de múltiples sesiones de trabajo, el repositorio incorpora una memoria de proyecto basada en la especificación **Google Open Knowledge Format (OKF v0.2)** y el patrón **LLM Wiki**.

### 4.1. Principios de la Base de Conocimiento Compilada

*   **Sustitución de RAG por Compilación**: En lugar de fragmentar documentos en fragmentos vectoriales y reinterpretar el contexto en cada consulta, el conocimiento del proyecto se precompila en páginas Markdown enlazadas con metadatos estructurados en YAML.
*   **Esquema de Tres Capas**:
    1.  `raw/`: Archivos fuente inmutables (especificaciones técnicas del servidor HP, manuales de hardware, límites de cuotas de las nubes gratuitas).
    2.  `wiki/`: Artículos compilados organizados en `concepts/`, `systems/` y `entities/`.
    3.  `index.md` y `log.md`: Archivos de navegación del grafo de conocimiento y bitácora cronológica acumulativa de cambios y decisiones arquitectónicas.
*   **Disciplina de Consulta Obligatoria**: Antes de generar o modificar código, el agente en Antigravity IDE debe consultar `index.md` y la página conceptual relevante, asegurando que se respeten los patrones previamente acordados.

### 4.2. Estructura de Directorios del Repositorio

```text
xeon-nexus-sentinel/
├── .github/
│   └── workflows/
│       └── deploy.yml              # Pipeline de compilación y publicación a GitHub Pages
├── AGENTS.md                       # Reglas operativas y directivas de estilo para Antigravity IDE
├── SPEC.md                         # Especificación técnica del formato OKF v0.2 aplicado al proyecto
├── index.md                        # Índice general y grafo de navegación para el LLM
├── log.md                          # Registro cronológico append-only de decisiones y tareas
├── raw/                            # Documentación inmutable de referencia
│   ├── hardware/
│   │   ├── hp-ml150-g6-specs.md
│   │   └── intel-xeon-lga1366.md
│   └── cloud/
│       └── free-tier-limits.md
├── wiki/                           # Conocimiento compilado bajo estándar OKF
│   ├── systems/
│   │   ├── almalinux-daemon.md
│   │   ├── cloud-relay-api.md
│   │   └── nextjs-dashboard.md
│   ├── concepts/
│   │   ├── cpu-inference-tuning.md
│   │   ├── randomx-cache-isolation.md
│   │   └── static-client-auth.md
│   └── entities/
│       ├── hp-server-node.md
│       └── windows-laptop-node.md
├── server/                         # Agente de telemetría y control para AlmaLinux 9
│   ├── daemon/
│   │   ├── collector.py            # Recolección de CPU, RAM, temperatura, IA y minería
│   │   ├── config.yaml             # Configuración de endpoints y umbrales de alerta
│   │   └── requirements.txt
│   ├── systemd/
│   │   └── xeon-sentinel.service    # Servicio systemd para ejecución en segundo plano
│   └── scripts/
│       ├── numa-tuning.sh          # Optimización de balanceo de memoria NUMA
│       └── ai-miner-governor.sh    # Control de afinidad y alternancia entre IA y minería
├── cloud-relay/                    # Microservicio Python para SaaS gratuito (Koyeb/Zeabur/Render)
│   ├── app/
│   │   ├── main.py                 # Endpoints FastAPI: /telemetry, /auth, /health
│   │   ├── auth.py                 # Validación de credenciales y generación de JWT
│   │   └── store.py                # Almacén de métricas en memoria volátil
│   ├── Dockerfile
│   └── requirements.txt
├── dashboard/                      # Aplicación Next.js (Frontend estático)
│   ├── package.json
│   ├── next.config.mjs             # Configuración output: 'export' y basePath para GitHub Pages
│   ├── tailwind.config.ts
│   ├── src/
│   │   ├── app/
│   │   │   ├── layout.tsx
│   │   │   ├── page.tsx            # Panel principal de telemetría
│   │   │   └── login/
│   │   │       └── page.tsx        # Interfaz de acceso con usuario y contraseña
│   │   ├── components/
│   │   │   ├── ServerMetrics.tsx   # Gráficas de CPU, RAM y temperaturas
│   │   │   ├── AiStatus.tsx        # Rendimiento de IA local (tokens/segundo, TTFT)
│   │   │   ├── MiningStatus.tsx    # Hashrate RandomX e hilos activos
│   │   │   └── AuthGuard.tsx       # Componente de protección de rutas y sesión
│   │   └── lib/
│   │       ├── api.ts              # Cliente de consumo HTTP hacia el Cloud Relay
│   │       └── crypto.ts           # Funciones criptográficas Web Crypto API
│   └── public/
└── README.md
```

---

## 5. Capa de Servicios REST en Python sobre Plataformas SaaS Gratuitas

Dado que el servidor local se encuentra en una red privada residencial y el frontend de GitHub Pages se distribuye como archivos estáticos, se implementa un microservicio intermedio en Python (*Cloud Relay*) sobre plataformas que ofrecen niveles de uso gratuitos permanentes o créditos mensuales renovables.

### Comparativa de Proveedores Gratuitos para Desplegar el Cloud Relay

La siguiente tabla compara las características de los proveedores en la nube analizados para alojar la API REST en Python sin costo:

| Proveedor Cloud | Cuota Gratuita de Cómputo | Política de Inactividad (Sleep) | Requiere Tarjeta | Idoneidad para el Relay |
| :--- | :--- | :--- | :--- | :--- |
| **Koyeb** | MicroVM con 512 MB RAM, 0.1 vCPU, 100 GB egress | Se suspende tras 1 hora sin tráfico | Sí (preautorización temporal) | Muy alta (mantiene la instancia tibia durante periodos activos) |
| **Zeabur** | Crédito de $5 USD mensuales renovables | Suspensión automática al agotar créditos o inactividad | No | Excelente (despliegue ágil sin riesgo de facturación inesperada) |
| **Render** | 512 MB RAM, 750 horas mensuales de cómputo | Se suspende tras 15 minutos de inactividad | No | Buena (requiere tolerar cold start de ~60 segundos tras pausas) |

### Mecánica de Comunicación del Relay

1.  **Ingestión Segura**: El daemon en AlmaLinux realiza peticiones periódicas `POST /api/telemetry` hacia la URL pública del Cloud Relay, protegiendo el payload mediante un token secreto precompartido (`X-Server-Token`).
2.  **Distribución y Control de Acceso**: El Cloud Relay expone el endpoint `GET /api/telemetry/latest`. Para acceder a los datos, el cliente debe presentar un encabezado `Authorization: Bearer <TOKEN>` emitido tras validar con éxito el usuario y la contraseña.
3.  **Gestión de Memoria Volátil**: El Relay mantiene una cola circular en memoria RAM con las últimas 100 muestras de telemetría, eliminando la necesidad de conectar una base de datos externa persistente y evitando cargos por almacenamiento.

---

## 6. Monitoreo Integral del Servidor: Hardware, Inferencia de IA y Criptominería

El daemon de recolección en AlmaLinux (`server/daemon/collector.py`) monitorea de forma coordinada tres áreas críticas de la máquina:

### 6.1. Métricas de Hardware y Sistema Operativo

*   **Uso de Procesador por Núcleo**: Lectura periódica de contadores en `/proc/stat` y frecuencias reales en `/proc/cpuinfo`.
*   **Estados Energéticos (C-States)**: Supervisión con la herramienta de kernel `turbostat` para evaluar el tiempo en estados de ahorro de energía versus estados de alto rendimiento.
*   **Memoria RAM y Topología NUMA**: Lectura de `/proc/meminfo` y monitoreo del balanceo entre canales de memoria mediante `numastat` para detectar accesos cruzados que aumenten la latencia.
*   **Temperaturas**: Consulta de sensores térmicos a través de `lm_sensors` o comandos de bajo nivel IPMI hacia el controlador BMC.

### 6.2. Monitoreo de Procesos de Inferencia de IA Local

*   **Modelos Cuantizados en CPU**: Ejecución de modelos ligeros adaptados a instrucciones vectoriales (como Llama 3.2 1B/3B, Qwen 2.5 0.5B/1.5B o Gemma 2B en formato GGUF con cuantización `Q4_K_M`).
*   **Métricas Evaluadas**:
    *   Velocidad de generación de tokens por segundo (`tok/s`).
    *   Tiempo hasta el primer token (TTFT).
    *   Memoria RAM ocupada por los pesos del modelo y la memoria intermedia de contexto (KV Cache).
*   **Aislamiento de Cómputo**: Restricción de afinidad de CPU mediante `taskset` o directivas `CPUAffinity` en `systemd` para reservar núcleos dedicados a tareas esenciales del sistema.

### 6.3. Monitoreo y Gobernanza de Criptominería (RandomX)

*   **Requisito Estricto de Caché L3**: El algoritmo RandomX exige **2 MB de memoria caché L3 por cada hilo de minería activo**. En procesadores Intel Xeon antiguos, el número de hilos de minería en XMRig debe configurarse de acuerdo con la fórmula matemática:

$$\text{Hilos Máximos} = \left\lfloor \frac{\text{Caché L3 Total en MB}}{2} \right\rfloor$$

Asignar más hilos de los permitidos por la caché física satura el bus de datos y destruye el rendimiento.

*   **Gobernanza de Convivencia con la IA**: La minería y la inferencia de lenguaje compiten severamente por el ancho de banda de la memoria RAM. El script de gobernanza (`ai-miner-governor.sh`) implementa un semáforo de recursos:
    *   Al detectar actividad de inferencia en el motor de IA, envía un comando de pausa al endpoint HTTP local del minero en localhost.
    *   Al terminar la generación de texto, el script reactiva la minería de fondo.
*   **Métricas Registradas**: Hashrate instantáneo (`H/s`), porcentaje de bloques/shares aceptados y temperatura del encapsulado térmico.

---

## 7. Frontend Next.js en GitHub Pages con Autenticación User/Password

El despliegue en GitHub Pages requiere compilar el frontend como un sitio puramente estático (`output: 'export'`), lo que significa que el servidor web de GitHub solo sirve archivos HTML, CSS y JavaScript precargados, sin posibilidad de ejecutar código Node.js dinámico en el servidor.

### Flujo de Autenticación Criptográfica para Sitios Estáticos

Para proteger el panel de control bajo estas condiciones:

1.  **Formulario de Acceso**: La aplicación dirige al usuario a una pantalla de inicio de sesión (`/login`).
2.  **Cifrado en el Navegador**: La contraseña ingresada no viaja en texto plano; el navegador calcula un resumen criptográfico mediante la Web Crypto API (SHA-256 o PBKDF2).
3.  **Validación en el Cloud Relay**: El hash resultante se envía al endpoint `/api/auth/login` del microservicio en Python. El servicio compara el valor contra las credenciales autorizadas configuradas en sus variables de entorno seguras (`ADMIN_USER` y `ADMIN_PASSWORD_HASH`) y genera un token JWT firmado.
4.  **Guardia de Rutas (`AuthGuard`)**: El componente `AuthGuard` verifica la presencia del token en `sessionStorage`. Si el token es válido, permite ver el panel; de lo contrario, intercepta la navegación y redirige al inicio de sesión.
5.  **Solicitudes Protegidas**: Todas las consultas a `/api/telemetry/latest` incluyen el token en el encabezado `Authorization: Bearer <TOKEN>`. Si un usuario intenta acceder directamente sin autenticación, la API rechaza la solicitud con un código HTTP `401 Unauthorized`.

---

## 8. Prompt Maestro para Inicialización en Antigravity IDE

A continuación se presenta el prompt completo, estructurado y listo para ser copiado en **Antigravity IDE** para inicializar el repositorio `merolhack/xeon-nexus-sentinel`:

```text
# INSTRUCCIÓN MAESTRA DE INICIALIZACIÓN: REPOSITORIO XEON-NEXUS-SENTINEL

Actúa como un Principal Systems Architect y Full-Stack Engineer. Tu objetivo es inicializar y construir de forma completa y funcional el repositorio merolhack/xeon-nexus-sentinel.

Este proyecto consiste en una plataforma integral de monitoreo, telemetría y administración para un servidor HP ProLiant (Intel Xeon) en modo headless con AlmaLinux 9 Minimal, integrado con una estación de trabajo Windows 11 (Ollama), microservicios REST en Python sobre infraestructura SaaS gratuita y un frontend estático en Next.js publicado en GitHub Pages con autenticación mediante usuario y contraseña.

---

### FASE 1: MEMORIA DEL CODEBASE (ESTÁNDAR GOOGLE OKF v0.2 + KARPATHY LLM WIKI)

Antes de escribir código funcional, inicializa la estructura de memoria agéntica del proyecto en la raíz del repositorio siguiendo el estándar Google Open Knowledge Format (OKF v0.2) y el patrón LLM Wiki:

1. Crea el archivo AGENTS.md con las reglas de ingeniería, guías de estilo y protocolo de consulta obligatoria para agentes en Antigravity IDE.
2. Crea el archivo SPEC.md documentando la taxonomía del conocimiento y los tipos de documentos (system, concept, entity, spec).
3. Crea el archivo index.md como índice raíz navegable para el modelo con enlaces relativos a cada sección del proyecto.
4. Crea el archivo log.md como bitácora append-only de decisiones técnicas y registro de tareas.
5. Crea el directorio raw/ con las especificaciones del servidor HP ProLiant ML150 G6 (Xeon LGA1366, RAM DDR3 ECC, red Gigabit y BMC iLO 100i).
6. Crea el directorio wiki/ con subdirectorios systems/, concepts/ y entities/. Cada archivo DEBE incluir el encabezado YAML formal de OKF:
   ---
   type: concept
   title: "Nombre del Elemento"
   description: "Descripción concisa para indexación rápida"
   tags: [monitoreo, almalinux, hardware]
   created: 2026-11-22
   updated: 2026-11-22
   ---
7. El agente DEBE consultar index.md y las notas pertinentes de wiki/ antes de ejecutar cualquier cambio de código en sesiones posteriores.

---

### FASE 2: FRONTEND NEXT.JS EN GITHUB PAGES (dashboard/)

* Framework y Tipado: Next.js 14+ con App Router, TypeScript y Tailwind CSS.
* Configuración de Exportación Estática:
  * Configurar next.config.mjs con output: 'export', trailingSlash: true, images: { unoptimized: true } y el basePath: '/xeon-nexus-sentinel'.
* Seguridad y Autenticación:
  * Implementar pantalla de inicio de sesión en /src/app/login/page.tsx con campos de usuario y contraseña.
  * Crear el componente AuthGuard.tsx que proteja las rutas privadas y almacene el token JWT de sesión en sessionStorage.
  * Diseñar la utilidad criptográfica en /src/lib/crypto.ts utilizando la Web Crypto API nativa.
* Paneles de Control (Dashboard):
  * Server Node: Visualización de uso de CPU por núcleo, memoria RAM, temperaturas y frecuencias de reloj.
  * AI Workloads: Estado del motor de inferencia local (Ollama en Windows 11 o llama.cpp en AlmaLinux), modelo activo, velocidad en tokens por segundo (tok/s) y latencia TTFT.
  * Mining Node: Hashrate instantáneo de RandomX (H/s), conteo de hilos activos (respetando la regla de 2 MB de caché L3 por hilo) y estado del semáforo de alternancia entre IA y minería.
  * Network & Management: Estado del enlace local Ethernet/WiFi, acceso web a Cockpit (puerto 9090) y telemetría del controlador HP iLO 100i.

---

### FASE 3: CLOUD RELAY API EN PYTHON PARA SAAS GRATUITO (cloud-relay/)

* Framework: Python 3.12 con FastAPI, Uvicorn y Pydantic.
* Optimización para PaaS Gratuito (Koyeb / Zeabur / Render):
  * Consumo mínimo de memoria (<100 MB RAM) y soporte tolerante a ciclos de inactividad (cold starts).
* Endpoints Requeridos:
  * POST /api/telemetry: Endpoint de ingestión protegido por encabezado X-Server-Token que recibe los datos desde el servidor AlmaLinux.
  * GET /api/telemetry/latest: Entrega las métricas más recientes al frontend Next.js (protegido por token Bearer).
  * POST /api/auth/login: Valida usuario y contraseña contra variables de entorno seguras (ADMIN_USER, ADMIN_PASSWORD_HASH) y emite un token JWT con tiempo de expiración.
  * GET /api/health: Comprobación de estado para servicios externos de monitoreo de disponibilidad.
* Archivos Requeridos: app/main.py, app/auth.py, app/store.py, Dockerfile y requirements.txt.

---

### FASE 4: AGENTE DE TELEMETRÍA Y GOBERNANZA EN ALMALINUX 9 (server/)

* Lenguaje: Python 3 sin entorno gráfico ni librerías pesadas.
* Módulos y Scripts:
  * collector.py: Recopila periódicamente el uso de CPU y memoria desde /proc/stat y /proc/meminfo, ejecuta consultas a numastat y turbostat, e interroga la API local del minero XMRig y Ollama/llama.cpp en localhost. Empaqueta los datos en formato JSON y los envía mediante POST al Cloud Relay.
  * ai-miner-governor.sh: Script de control que monitorea la actividad del proceso de IA; al detectar inferencia activa, suspende la minería en XMRig para liberar el bus de memoria, y la reanuda cuando la inferencia concluye.
  * xeon-sentinel.service: Unidad de servicio para systemd que garantiza la ejecución continua del daemon en segundo plano y su reinicio ante fallos.

---

### FASE 5: INTEGRACIÓN Y AUTOMATIZACIÓN CI/CD (.github/workflows/deploy.yml)

* Configura un pipeline de GitHub Actions que al recibir cambios en la rama main:
  1. Instale las dependencias de Node.js y ejecute npm run build.
  2. Extraiga los artefactos estáticos generados en dashboard/out/.
  3. Publique de forma automática el contenido en la rama gh-pages para habilitar el sitio web público en GitHub Pages.

---

### FASE 6: DOCUMENTACIÓN DEL REPOSITORIO (README.md)

* Genera un archivo README.md exhaustivo y profesional que explique:
  1. La arquitectura general del sistema y el flujo de telemetría.
  2. Guía paso a paso para la configuración headless del servidor HP ProLiant (conexión con cable de red, acceso por SSH con llaves ED25519, administración mediante Cockpit en el puerto 9090 y uso del convertidor activo VGA a HDMI para diagnóstico).
  3. Instrucciones de despliegue del Cloud Relay en Koyeb, Zeabur o Render.
  4. Configuración de credenciales de acceso y variables de entorno para GitHub Pages y el Cloud Relay.

Genera la estructura de directorios, los archivos de memoria OKF y todo el código modular, tipado y completamente funcional.
```


================================================================================
# FILE: raw/cloud/free-tier-limits.md
================================================================================

# Restricciones y Cuotas Inmutables de Plataformas SaaS Gratuitas

## 1. GitHub Pages
- **Tipo de Hosting:** Distribución estática pura (HTML, JS, CSS, Media).
- **Límite de Ancho de Banda:** 100 GB por mes.
- **Tamaño Máximo del Repositorio:** 1 GB recomendado.
- **Límite de Compilación (Build):** 10 minutos por ejecución.
- **Requisito Clave:** Para aplicaciones Next.js se requiere compilación estática (`output: 'export'`) y `images: { unoptimized: true }`.

## 2. Koyeb (Nivel Free Eco)
- **Instancia:** MicroVM con 512 MB de RAM y 0.1 vCPU compartida.
- **Tráfico:** 100 GB mensuales de transferencia de salida (egress).
- **Inactividad:** Se suspende automáticamente tras 60 minutos sin recibir tráfico HTTP.
- **Arranque en Frío:** Reactivación rápida en ~3 a 5 segundos.

## 3. Zeabur (Crédito Gratuito)
- **Crédito:** $5 USD mensuales sin vencimiento con renovación periódica.
- **Consumo:** Cobro por segundo de CPU y memoria RAM.
- **Inactividad:** Posibilidad de configurar suspensión ante bajo uso.
- **Ventaja:** Despliegue directo desde repositorio GitHub y sin requerimiento de tarjeta de crédito.

## 4. Render (Nivel Free Web Service)
- **Instancia:** 512 MB RAM compartida y 0.1 vCPU.
- **Tiempo de Cómputo:** 750 horas por mes (suficiente para un servicio 24/7 continuo).
- **Inactividad:** Entra en suspensión (*sleep*) tras 15 minutos sin tráfico entrante.
- **Arranque en Frío (Cold Start):** Demora entre 50 y 90 segundos al recibir la primera petición tras suspensión.


================================================================================
# FILE: raw/hardware/hp-ml150-g6-specs.md
================================================================================

# Ficha Técnica Inmutable: Servidor HP ProLiant ML150 G6

## Especificaciones del Sistema

* **Modelo:** HP ProLiant ML150 G6 (Torre / Bastidor 5U)
* **Arquitectura de Procesador:** Dual Socket Intel LGA1366
* **Chipset:** Intel 5520 / 5500
* **Controlador de Gestión Remota:** HP Integrated Lights-Out 100i (iLO 100i BMC)
  * Protocolos: IPMI 2.0, Virtual KVM, Interfaz Web dedicada, Puerto Fast Ethernet 10/100 RJ-45
* **Memoria Soportada:**
  * Ranuras: 12 ranuras DIMM (6 por procesador)
  * Tipo: DDR3 Registered (RDIMM) o Unbuffered (UDIMM) ECC
  * Canales: 3 canales de memoria por zócalo (Triple-Channel)
  * Frecuencias: 800 / 1066 / 1333 MHz
* **Almacenamiento:**
  * Controlador SATA/SAS HP Smart Array B110i o P410
  * Bahías: Hasta 4 bahías LFF (3.5 pulgadas) Non-Hot Plug o Hot Plug
* **Interfaces de Red:**
  * Controladora integrada HP NC107i Gigabit Server Adapter (10/100/1000 Mbps)
* **Salida de Vídeo:**
  * Chipset gráfico integrado Matrox G200e (32 MB SDRAM) con puerto analógico VGA DB-15 trasero.
* **Alimentación Eléctrica:**
  * Fuente de poder estándar 460W Non-Hot Plug / 750W Hot Plug (eficiencia 80 PLUS).


================================================================================
# FILE: raw/hardware/intel-xeon-lga1366.md
================================================================================

# Ficha Técnica Inmutable: Arquitectura Intel Xeon LGA1366 (Nehalem / Westmere)

## Características del Microprocesador

* **Zócalo:** LGA 1366 (Socket B)
* **Familias Comunes:**
  * Nehalem-EP (45nm): Xeon 5500 Series (ej. E5520, X5570) - 4 núcleos / 8 hilos
  * Westmere-EP (32nm): Xeon 5600 Series (ej. E5620, X5650, X5675) - 4 o 6 núcleos / 8 o 12 hilos
* **Conjunto de Instrucciones:**
  * x86-64, MMX, SSE, SSE2, SSE3, SSSE3, SSE4.1, SSE4.2
  * **NOTA CRÍTICA:** No soporta instrucciones AVX, AVX2 ni AVX-512. La inferencia de modelos de lenguaje debe compilarse específicamente para SSE4.2 en `llama.cpp`.
* **Topología de Caché:**
  * L1: 32 KB datos + 32 KB instrucciones por núcleo
  * L2: 256 KB dedicados por núcleo
  * L3 (Smart Cache Compartida): 8 MB (Nehalem 4 núcleos) o 12 MB (Westmere 6 núcleos)
* **Interconexión QuickPath Interconnect (QPI):**
  * Enlaces punto a punto entre procesadores y chipset a 4.8 GT/s, 5.86 GT/s o 6.4 GT/s.
* **Controlador de Memoria Integrado (IMC) y NUMA:**
  * Arquitectura Non-Uniform Memory Access (NUMA).
  * Cada procesador posee acceso directo a sus bancos de memoria local de triple canal. El acceso a la memoria del segundo socket atraviesa el bus QPI, incrementando la latencia en ~30-40%.


================================================================================
# FILE: log.md (HISTORIAL Y BITÁCORA RECIENTE)
================================================================================

# Bitácora de Decisiones de Arquitectura y Sesiones (log.md)

Registro cronológico acumulativo (append-only) de decisiones de diseño, tareas ejecutadas y cambios estructurales en el ecosistema **Xeon-Nexus-Sentinel**.

---

## [2026-11-22] Inicialización del Repositorio y Arquitectura Base

- **Autor / Agente:** Antigravity IDE (Principal Systems Architect)
- **Objetivo:** Inicialización integral del repositorio `merolhack/xeon-nexus-sentinel` bajo especificación OKF v0.2, Karpathy LLM Wiki, frontend Next.js en GitHub Pages, microservicio FastAPI Cloud Relay y daemon en AlmaLinux 9.

### Decisiones Técnicas Clave:
1. **Memoria Agéntica OKF v0.2:** Se estructura la base de conocimiento en tres capas (`raw/`, `wiki/`, `index.md`, `log.md`, `AGENTS.md`) para proporcionar contexto persistente y evitar pérdida de estado.
2. **Despliegue Estático con Autenticación Cliente:** Al operar sobre GitHub Pages (`output: 'export'`), la autenticación se delega a Web Crypto API (SHA-256) con validación mediante token JWT generado en el Cloud Relay.
3. **Aislamiento de Recursos IA vs Criptominería:** Para procesadores Xeon con memoria compartida, se establece la regla de oro de RandomX (2 MB caché L3 por hilo) y un semáforo de gobernanza en segundo plano que pausa la minería durante inferencias locales.
4. **Conexión de Gemini Notebook:** Se configuró el ID de cuaderno `1bd607be-628c-4228-a1f5-5b4f5dd59093` con sincronización bidireccional mediante `scripts/sync-wiki-to-notebook.mjs` y el servidor MCP `notebooklm-mcp`.
5. **Codebase Memory Graph:** Registro inicial e indexación en el servidor MCP `codebase-memory` (465 nodos, 669 aristas).
6. **Confirmación Gemini Notebook:** El usuario confirmó la recepción y visualización de la fuente `XEON-NEXUS-SENTINEL-LLM-WIKI-MASTER.md` en el cuaderno oficial `1bd607be-628c-4228-a1f5-5b4f5dd59093`.
7. **Resolución CI/CD Next.js:** Compilación y exportación estática validada localmente al 100%, generando `dashboard/package-lock.json` para el pipeline de GitHub Actions hacia GitHub Pages.
8. **DevSecOps y Cero Secretos (GitGuardian):** Análisis e integración de protección contra fuga de credenciales. Creación de `scripts/scan-secrets.sh`, `.githooks/pre-commit` y documentación en `wiki/concepts/secrets-management-and-gitguardian.md`. Confirmación de sincronización en Gemini Notebook recibida.
9. **Evaluación PaaS Gratuito y Ajuste UI Login:** Análisis comparativo de Koyeb, Zeabur y Render. Selección de Render como solución 100% gratuita (750 horas mensuales sin tarjeta requerida y suspensión automática a los 15 min). Incorporación de selector de URL del Cloud Relay en `/login/` para resolver bloqueos por Mixed Content y creación de `render.yaml` Blueprint. Confirmación de sincronización en Gemini Notebook recibida.
10. **Endurecimiento de Credenciales y Remoción de Huellas:** Cambio de usuario maestro a `administrador`. Cálculo del hash SHA-256 (`ea51164dd668d869a14e71ec9a54f1ea60df5f71e7db86fa3a7fdd79c74e9e2a`), eliminación total de credenciales o pistas en el frontend, generación y rotación de `JWT_SECRET_KEY` y `SERVER_INGEST_TOKEN` en Cloud Relay y Daemon.
11. **Despliegue Exitoso en Render y Gestión .env:** Despliegue en Render verificado en vivo (`https://xeon-nexus-cloud-relay.onrender.com`). Creación de `.env` protegido por `.gitignore` y `.env.example` con plantilla pública. Ajuste de URL por defecto en frontend a HTTPS de Render y ruta raíz `@app.get("/")` en FastAPI. Confirmación de sincronización en Gemini Notebook recibida.
12. **Auditoría y Resolución de Incidentes GitGuardian:** Detección y saneamiento de incidentes #40868161, #40868162 y #40869194. Remoción de literales de alta entropía en `cloud-relay/app/auth.py`, `server/daemon/config.yaml`, `render.yaml` y `.env.example`. Configuración de `GITGUARDIAN_API_KEY` en `.env` y en GitHub Secrets. Script de resolución vía REST API ejecutado exitosamente. Confirmación de sincronización en Gemini Notebook recibida.
13. **Mantenimiento de Almacenamiento y Herramienta Rclone:** Limpieza preventiva a nivel de usuario en Windows 11 recuperando 19.91 GB de espacio libre (C: de 8.94 GB a 28.85 GB) y 33 GB en WSL (/dev/sdd de 85 GB a 52 GB usados). Creación de scripts `clean-space.ps1` e instalación exitosa de `rclone v1.76.0` en `C:\Users\lenin\rclone` incorporado al PATH del usuario sin requerir elevación de administrador.
14. **Verificación de Google Drive (5 TiB) y Script de Respaldo:** Autenticación OAuth de `rclone` completada exitosamente para el remoto `gdrive:`. Verificación de cuota con `rclone about gdrive:` confirmando 5 TiB totales y 4.899 TiB disponibles. Creación de `scripts/gdrive-backup.ps1` con soporte para `Copy`, `Move` (liberación de espacio tras verificación), `Sync`, filtro por antigüedad (`-MinAgeDays`) y simulación preventiva (`-DryRun`). Documentación registrada en `wiki/concepts/storage-optimization-and-gdrive-backup.md`.
15. **Auditoría de Inactivos y Respaldo Atómico a gdrive:Backup:** Consulta a `ollama-local` y `notebooklm-mcp` para filtrado temporal seguro previo a 2026. Creación del directorio remoto `gdrive:Backup`. Auditoría local detectando 152,161 archivos inactivos (27.17 GB) concentrados en Documents (Photos 8.88 GB, Freelances 10.57 GB, Personal 1.83 GB) y Music (1.03 GB). Ejecución exitosa de `rclone move` con filtro `--min-age 2026-01-01` en `C:\Users\lenin\Music`: 16 archivos (1.029 GiB) transferidos y verificados con SHA-1 en la nube, y eliminados de forma segura del almacenamiento local preservando archivos modificados en 2026.
16. **Restauración de Música y Filtro Dual de Inactividad (Escritura + Acceso):** Restauración completa de `gdrive:Backup/Music` hacia `C:\Users\lenin\Music` (16 pistas, 1.029 GiB restablecidas localmente). Análisis de telemetría NTFS en Windows 11 (`DisableLastAccess = 2` habilitado): se constató que de 152,146 archivos con escritura anterior a 2026, 40,842 archivos (23.77 GB) fueron efectivamente abiertos o utilizados en 2026 y deben ser protegidos. Se actualizó `scripts/gdrive-backup.ps1` con el switch `-CheckLastAccess`, evaluando `LastWriteTime < corte` AND `LastAccessTime < corte` vía `--files-from-slash`, aislando los 111,304 archivos verdaderamente inactivos (2.37 GB). Depuración de 7 fuentes duplicadas en Gemini Notebook dejando únicamente la versión maestra.
17. **Post-Mortem y Política Anti-Bloqueo de Timeouts:** Análisis del incidente de bloqueo de 39 minutos originado por una llamada de sondeo `curl` sin timeout enviada a segundo plano esperando notificación pasiva. Se formuló el Mandato 6 en `AGENTS.md` y se documentó `wiki/concepts/execution-timeouts-and-anti-hang-patterns.md`, estableciendo la prohibición terminante de ejecutar comandos de red sin `--max-time 10` o `-TimeoutSec 5`, y prohibiendo delegar verificaciones ligeras a tareas de fondo sin guardia de tiempo.
18. **Pipeline Headless PXE Netboot para AlmaLinux 9:** Descarga completada con timeouts estrictos del kernel (`vmlinuz`, 14.62 MB) e initrd (`initrd.img`, 218.16 MB) desde el repositorio oficial de AlmaLinux 9 BaseOS. Creación del script autónomo `scripts/headless_pxe_server.py` en Python puro (TFTP UDP 69, HTTP TCP 8000, DHCP/ProxyDHCP UDP 67/4011). Implementación de discriminación inteligente por Opción 175 para prevenir bucles infinitos de iPXE y configuración de Kickstart (`ks.cfg`) 100% desatendido en modo texto con OpenSSH habilitado de fábrica y contraseña de root para acceso inmediato tras la instalación sin requerir periféricos físicos ni medios ópticos/USB. Creación del lanzador `iniciar-servidor-pxe.bat` y documentación en `wiki/systems/headless-pxe-netboot.md`.
19. **Resolución de Arranque: Detección de Windows Server 2008 R2 y Estrategia Híbrida CD-R iPXE:** Mediante la energización USB del adaptador activo VGA a HDMI conectado a la TV se obtuvo señal de video, revelando que el servidor tiene Windows Server 2008 R2 Enterprise instalado en un arreglo Smart Array P410 y que el BIOS prioriza el disco local sobre PXE. Ante la ausencia de teclado físico en el servidor y la imposibilidad de grabar el ISO de AlmaLinux de 1.55 GB en un CD-R (límite 700 MB), se adoptó la estrategia de arranque híbrido: descarga de `ipxe.iso` (9 MB) en `C:\Users\lenin\pxeboot\ipxe.iso` para su grabación en CD-R mediante la grabadora externa USB Philips (unidad E:). Al arrancar, el BIOS lee el CD primero e iPXE enlaza inmediatamente con el servidor PXE/HTTP en la laptop por el puerto Gigabit inferior para instalar AlmaLinux 9 desatendido vía Kickstart.
20. **Registro Integral de Pruebas Físicas con el Servidor y Sincronización con Gemini Notebook:** Consolidación de los resultados de campo en la base de conocimiento: diagnóstico de salida de video analógico-digital Matrox G200 con conversor activo VGA a HDMI energizado por USB (5V); verificación de puertos Ethernet Gigabit HP NC107i (puerto 1/Mgmt para enlace directo con laptop 192.168.137.1); pruebas de sondeo y escaneo de red con timeouts anti-bloqueo (`scan-ics-range.ps1`, `detect-ilo.ps1`, `monitor-hp-ip.ps1`); automatización y finalización exitosa de la grabación de `ipxe.iso` (9 MB) en CD-R virgen de 700 MB mediante `scripts/burn-iso.ps1` e `isoburn.exe` con unidad PHILIPS CDRW/DVD SCB5265 (Unidad E:). Actualización de `wiki/entities/hp-server-node.md`, `wiki/systems/headless-pxe-netboot.md`, exclusión de autorreferencia en `scripts/sync-wiki-to-notebook.mjs` y sincronización del compendio maestro `XEON-NEXUS-SENTINEL-LLM-WIKI-MASTER.md` en Gemini Notebook (`1bd607be-628c-4228-a1f5-5b4f5dd59093`).
21. **Diagnóstico Acústico de Beeps, Identificación de Discos SAS y Estrategia Cero-Teclado:** Pruebas de arranque físico y diagnóstico del comportamiento de la controladora HP Smart Array P410. Al retirar las charolas de discos, la controladora emitió 2 beeps cortos de advertencia (`1785-Slot X Drive Array - Drive(s) Not Detected, Press F1 to continue`) deteniendo el POST. Al reinsertar los dos discos SAS Hot-Plug de 450 GB 15K RPM (HP Spare 517352-001) y reiniciar, el servidor emitió 1 beep corto (POST exitoso) y continuó hacia Windows Server 2008 R2 ("Aplicando la configuración del equipo"), confirmando el 100% de salud física de la placa base, dual Xeon, memoria ECC y arreglo de almacenamiento. Detección de pérdida de sincronismo en el conversor VGA-HDMI durante la transición gráfica a modo texto. Puesta en marcha exitosa del servidor autónomo `headless_pxe_server.py` en la laptop (puertos 67, 4011, 69, 8000). Formulación de la estrategia operativa estricta sin teclado físico: interacción gráfica mediante ratón USB conectado al puerto frontal y Teclado en Pantalla (`osk.exe`) vía menú de Accesibilidad, y plan de borrado de MBR (`diskpart clean`) para forzar al BIOS a realizar fallback desatendido hacia el CD-R de iPXE o PXE Netboot para la instalación automática de AlmaLinux 9.
22. **Setup Interactivo de BIOS, Aislamiento de Memoria RAM (8 GB), Bloqueo de Windows y Ajuste de Servidor PXE:** Intervención en el firmware del HP ProLiant ML150 G6 mediante teclado USB pulsando `F10` (AMI BIOS v02.61, ROMID 021). Validación de 8192 MB (8 GB) limpios en ranuras primarias blancas `DIMM2A` y `DIMM4B` con módulos Micron/IBM DDR3 ECC Registered, y detección de CPU Intel Xeon E5504 @ 2.00GHz y MAC `44:1E:A1:6E:D2:E4`. Identificación de Windows Server 2008 R2 Enterprise bloqueado bajo el dominio `gppan.senado.gob.mx\administrador`. Modificación del orden de arranque en el BIOS: `1st Boot Device [CD/DVD]`, `2nd Boot Device [Network:MBA v11.0.]` y `3rd Boot Device [Disabled]`, erradicando definitivamente el secuestro de Windows. Verificación de tráfico PXE en tiempo real (solicitudes `DHCP DISCOVER` de la MAC `44:1E:A1:6E:D2:E4` recibidas por la laptop en puerto 67). Diagnóstico de enrutamiento broadcast en Windows 11 (`255.255.255.255` desviado hacia Wi-Fi) y refactorización de `headless_pxe_server.py` con Subnet Directed Broadcast (`192.168.137.255:68`) y remoción de la Opción 60 en puerto 67 para compatibilidad directa con Broadcom MBA v11.0. Detección de estado Halt / Boot Failure del servidor al no contar con medios ópticos/USB listos, apagando el DAC de vídeo Matrox G200e ("Sin señal"). Sincronización modular de la LLM Wiki y consulta especializada a Gemini Notebook para siguientes pasos sin depender de memoria USB.
23. **Arranque de Kernel Linux, Framebuffer Matrox G200e, Resolución de Error SSL y Despliegue de BaseOS:** Inicio exitoso de AlmaLinux 9 vía iPXE Netboot desatendido sin teclado ni USB. Detección completa del subsistema de almacenamiento SCSI Smart Array P410 como `/dev/sda` (discos SAS 450 GB 15K RPM), unidad óptica `hp DVDROM DH40N` y enlace Gigabit a 1000 Mbps Full Duplex (`tg3` en `enp4s0`). Inicialización del framebuffer nativo `mgag200` en consola 128×48 caracteres recuperando señal de vídeo estable en la TV LG. Detección y resolución del fallo de validación de certificados SSL (`curl: 60 certificate is not yet valid`) provocado por el reloj del BIOS en 2011 (`01/18/2011`), subsanado mediante redirección de repositorios a HTTP plano (`http://repo.almalinux.org/...`) y switches `inst.noverifyssl` y `--noverifyssl`. Transferencia exitosa de más de 1.4 GB de paquetes RPM base mediante ICS e inicio del particionado automatizado Kickstart. Consulta especializada a Gemini Notebook respecto a esquema óptimo de particionado y sistema de archivos (XFS vs ext4) para cargas de servidor, IA local y minería.
24. **Conclusión de Instalación de AlmaLinux 9, Reinicio de Servidor e Investigación Arquitectónica de Strata:** Finalización de la instalación automatizada Kickstart transfiriendo más de 2.48 GB de paquetes RPM a través del enlace Gigabit y reinicio autónomo del servidor HP ProLiant ML150 G6. Detección de re-intentos de red PXE debido a la configuración de BIOS previa (`Hard Drive Disabled`). Formulación del procedimiento interactivo de BIOS para fijar `1st Boot Device [Hard Drive]` con Smart Array P410. Investigación exhaustiva en Gemini Notebook a partir de nuevas fuentes sobre el motor de inferencia Strata (`Niko1221/Strata`, `Strata-GLM`): análisis de jerarquía de memoria en 3 niveles (VRAM GPU, Arena de RAM anclada y Page Cache en NVMe para tabla n-gram), aceleración MTP y evaluación comparativa frente a Ollama / `llama.cpp`. Identificación de barreras de hardware en el nodo Xeon E5504 (carencia de AVX/AVX2, 8 GB de RAM vs 32–64 GB exigidos por Strata para MoE 125B y discos mecánicos SAS vs NVMe), confirmando a `llama.cpp` SSE4.2 como la solución óptima actual para modelos compactos de 1B a 3B y definiendo la hoja de ruta de ampliación a 48 GB de RAM y GPU PCIe para adopción futura de Strata.
25. **Gobernanza de Memoria RAM DDR3 ECC (RDIMM vs UDIMM), Aislamiento de Hardware y Diagnóstico de Arranque BIOS/Smart Array:** Análisis exhaustivo de los módulos de memoria del servidor tras la intervención del usuario. Esclarecimiento del inventario real: 2 módulos adquiridos Micron 4 GB `PC3-10600R` (`MT36JBZS51272PY`, Registered ECC RDIMM de grado servidor genuino) frente a 3 módulos preexistentes heredados del chasis (2× Nanya 4GB + 1× Samsung 2GB `PC3-10600E` UDIMM Unbuffered ECC). Demostración técnica de la incompatibilidad absoluta impuesta por el código de referencia de memoria (MRC) de Intel y la BIOS AMI del HP ProLiant ML150 G6, que prohíbe terminantemente la coexistencia de RDIMM y UDIMM en la misma placa base o entre diferentes sockets en configuraciones de doble procesador. Validación de la compra en MercadoLibre como la elección correcta y formulación de la directiva de expansión futura (adquisición exclusiva de módulos RDIMM `PC3-10600R` para alcanzar 24 GB o 48 GB). Diagnóstico del síntoma "Sin señal" y bloqueo aparente de arranque: detección de la pausa obligatoria de la BIOS por cambio de capacidad de RAM (`Memory size changed, Press F1`), desincronización de frecuencia del conversor VGA-HDMI con el chip gráfico Matrox G200e y formulación de los ajustes de firmware críticos (`Quick Boot [Disabled]` para permitir la inicialización de discos SAS 15K RPM y `Select Boot Volume` en la Option ROM F8 de la Smart Array P410). Creación del documento modular `wiki/concepts/server-memory-and-bios-governance.md` y actualización integral de `wiki/entities/hp-server-node.md` e `index.md`.



