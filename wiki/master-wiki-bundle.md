# XEON-NEXUS-SENTINEL-LLM-WIKI-MASTER.md
- Cuaderno Oficial: https://notebook.google.com/notebook/1bd607be-628c-4228-a1f5-5b4f5dd59093
- Arquitectura: Google OKF v0.2 + Karpathy LLM Wiki


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

### 2. Conceptos y Protocolos de Ingeniería (`wiki/concepts/`)
* [cpu-inference-tuning.md](file:///wiki/concepts/cpu-inference-tuning.md) — Optimización de inferencia cuantizada (GGUF Q4_K_M) en arquitecturas Intel Xeon legadas sin AVX2.
* [randomx-cache-isolation.md](file:///wiki/concepts/randomx-cache-isolation.md) — Regla de afinidad y memoria caché L3 (2 MB por hilo) para minería RandomX y gobernanza con IA.
* [static-client-auth.md](file:///wiki/concepts/static-client-auth.md) — Esquema de autenticación criptográfica en el cliente mediante Web Crypto API y tokens JWT.

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
# FILE: log.md
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
5. **Codebase Memory Graph:** Registro inicial e indexación en el servidor MCP `codebase-memory`.


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
# FILE: wiki/entities/hp-server-node.md
================================================================================

---
type: entity
title: "Nodo Físico: Servidor HP ProLiant ML150 G6"
description: "Servidor empresarial torre de doble zócalo Xeon operando en modo headless con AlmaLinux 9 Minimal"
tags: [servidor, hp-proliant, almalinux, headless, ilo, xeon]
created: 2026-11-22
updated: 2026-11-22
---

# Nodo Físico: Servidor HP ProLiant ML150 G6 (`hp-server-node`)

## 1. Identificación y Rol

* **Hostname Local:** `xeon-sentinel.local` o IP estática en red interna.
* **Sistema Operativo:** AlmaLinux 9.x Minimal (x86_64, sin interfaz gráfica).
* **Modo Operativo:** Headless continuo (sin teclado ni monitor conectados).
* **Propósito:** Nodo de cómputo en segundo plano para minería RandomX de baja prioridad, ejecución cuantizada de modelos ligeros con `llama.cpp` y recolección de métricas.

## 2. Puntos de Entrada y Control

* **HP iLO 100i (BMC):** Puerto Ethernet dedicado. Permite control de energía (power-on/reboot forzado) e inspección de salud térmica.
* **OpenSSH (Puerto 22):** Acceso administrativo seguro mediante llave criptográfica `ed25519`.
* **Cockpit (Puerto 9090):** Panel web nativo para gestión de discos, red, paquetes y terminal web directa.
* **Daemon Local (xeon-sentinel):** Servicio systemd que recopila telemetría y controla el gobernador de alternancia.


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
