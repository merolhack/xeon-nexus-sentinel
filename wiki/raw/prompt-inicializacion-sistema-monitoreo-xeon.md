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
