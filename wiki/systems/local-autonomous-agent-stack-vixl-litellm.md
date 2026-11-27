---
type: system
title: "Stack de Agente Autónomo Local: Vixl, LiteLLM, Ollama y Servidores MCP"
description: "Documentación técnica del stack agéntico local sin suscripciones: interfaz Vixl, proxy LiteLLM para bypass de thinking en Qwen3, servidor Ollama y herramientas MCP"
tags: [vixl, litellm, ollama, qwen3-8b, mcp, autonomous-agent, local-ai, tool-calling]
created: 2026-11-27
updated: 2026-11-27
---

# Stack de Agente Autónomo Local: Vixl, LiteLLM, Ollama y Servidores MCP

## 1. Resumen Ejecutivo y Propósito
El objetivo del stack es transformar un modelo de lenguaje local (`qwen3:8b-8k` / `qwen3:8b-agent`) ejecutado en la GPU de la laptop en un **agente autónomo funcional** capaz de interactuar con el sistema de archivos, buscar en la web mediante DuckDuckGo y procesar imágenes mediante visión local, replicando las capacidades de entornos comerciales (*Antigravity*, *Claude Code*, *Cursor*) con **cero costo de suscripción y 100% de privacidad**.

### Arquitectura de Integración:
* **Vixl (Host MCP e Interfaz):** Actúa como IDE y orquestador de herramientas (`vixl.exe` con configuración en `~/.vix/` y `~/.vixl/`).
* **LiteLLM (Proxy Traductor):** Proxy local en Python (`litellm-env` en puerto 4000) que resuelve incompatibilidades de protocolo entre Vixl y Ollama, eliminando tokens de razonamiento (*thinking*) que bloquean el *tool use*.
* **Ollama (Motor de Inferencia GPU):** Servidor local (`http://127.0.0.1:11434/v1`) ejecutando variantes optimizadas de `qwen3` aceleradas por la NVIDIA RTX 4060.
* **Servidores MCP:** Herramientas estandarizadas bajo el Model Context Protocol para lectura de archivos, memoria persistente, búsqueda web y visión local.

```text
[ Usuario ]
    │
    ▼
[ Vixl (Host MCP) ] ─── (Peticiones OpenAI-compatible en puerto 4000) ──► [ LiteLLM (Proxy) ]
    │                                                                           │
    ├─► [ MCP: filesystem ]                                                     │ (Inyección de reasoning_effort: "none")
    ├─► [ MCP: web-search ]                                                     ▼
    ├─► [ MCP: memory ]                                                 [ Ollama (API /v1 en puerto 11434) ]
    └─► [ MCP: local-vision ] ◄── (Visión con qwen3-vl:8b-instruct) ──── [ qwen3:8b-agent (16K context) ]
```

---

## 2. Fase 1: Configuración Base de Vixl y Ollama

### 2.1. El Problema del Protocolo de Respuestas y `providers.json`
Vixl se comunica con los motores mediante una API compatible con OpenAI. No obstante, por defecto, Vixl intentaba invocar la **API de "Responses"**, no implementada en Ollama, produciendo el error crítico:
`unknown input item type: "item_reference"` al intentar encadenar llamadas a herramientas.

**Solución Implementada:**
Se creó el archivo `providers.json` forzando el dialecto clásico de *Chat Completions*:
* **Ruta de Configuración:** `C:\Users\lenin\.vix\providers.json`
* **Definición Clave:** `"wire_api": "chat"` con base URL `http://127.0.0.1:11434/v1`.

### 2.2. Ampliación de la Ventana de Contexto (`num_ctx`)
El modelo base `qwen3:8b-8k` venía limitado a 8,192 tokens. Este espacio resultaba insuficiente para alojar simultáneamente el prompt de sistema del agente, los esquemas JSON de las herramientas MCP y el historial de conversación.

**Solución Implementada:**
Se creó la variante especializada `qwen3:8b-agent` mediante un `Modelfile` en Ollama:
```dockerfile
FROM qwen3:8b-8k
PARAMETER num_ctx 16384
SYSTEM /no_think
```
*Comando de generación:* `ollama create qwen3:8b-agent -f Modelfile`

---

## 3. Fase 2: Integración de Herramientas MCP en Vixl

En el archivo `C:\Users\lenin\.vixl\mcp.json` se habilitaron cuatro servidores bajo el protocolo abierto Model Context Protocol:

1. **`filesystem` (Acceso a Archivos Locales):**
   * *Comando:* `npx -y @modelcontextprotocol/server-filesystem C:\Users\lenin\Documents`
   * *Función:* Lectura, edición y exploración del directorio de trabajo.
2. **`memory` (Memoria Persistente a Largo Plazo):**
   * *Comando:* `npx -y @modelcontextprotocol/server-memory`
   * *Función:* Grafo de conocimiento de entidades y relaciones para recordar contexto entre sesiones.
3. **`web-search` (Búsqueda Web Gratuita):**
   * *Comando:* `npx -y @zhafron/mcp-web-search`
   * *Función:* Búsquedas en internet en vivo mediante DuckDuckGo sin requerir API keys ni suscripciones.
4. **`local-vision` (Inspección Visual con VLM Local):**
   * *Comando:* `uvx --with fastmcp==2.12.2 mcp-local-vision`
   * *Variables de Entorno:* `VISION_MODEL=qwen3-vl:8b-instruct` y `VISION_OLLAMA_HOST=http://127.0.0.1:11434`
   * *Función:* Permite al agente analizar capturas de pantalla e imágenes locales enviándolas al modelo multimodal local.

---

## 4. Fase 3: Despliegue de LiteLLM Proxy para Control de "Thinking"

### 4.1. El Bucle Infinito del Modo de Pensamiento (Thinking Loop)
A pesar de la configuración inicial, `qwen3:8b-agent` se atascaba emitiendo cadenas de razonamiento en el campo `reasoning` interno sin ejecutar las llamadas a herramientas ni entregar respuestas finales. Esto ocurría porque Vixl no enviaba el parámetro requerido por Ollama para silenciar el modo de pensamiento en su endpoint `/v1`.

### 4.2. Aislamiento en Entorno Virtual Dedicado
Para prevenir conflictos de dependencias entre librerías (como el conflicto entre `gtts` y `huggingface-hub` por la versión de `click`), se creó un entorno virtual aislado en Windows:
* **Ubicación:** `C:\Users\lenin\Documents\AIDevelopment\ollama\qwen3-8b-8k\litellm-env`
* **Instalación:** `pip install "litellm[proxy]"`

### 4.3. Configuración del Proxy (`config.yaml`)
LiteLLM intercepta las peticiones de Vixl e inyecta la orden estricta de desactivar el razonamiento antes de despachar a Ollama:

```yaml
model_list:
  - model_name: qwen3-agent-no-think
    litellm_params:
      model: openai/qwen3:8b-agent
      api_base: http://127.0.0.1:11434/v1
      api_key: "ollama"
      reasoning_effort: "none" # Desactiva el modo thinking en Ollama

litellm_settings:
  drop_params: true # Descarta parámetros de OpenAI no soportados por Ollama

general_settings:
  master_key: "sk-litellm-local-key-12345" # Clave de autorización local
```

### 4.4. Configuración en Vixl (`settings.json`)
* **Proveedor Custom:** `providers.custom.litellm`
* **Base URL:** `http://localhost:4000/v1`
* **API Key:** `sk-litellm-local-key-12345`
* **Model ID:** `qwen3-agent-no-think` (mapeado a roles de agente, orquestador y planificación).

---

## 5. Fase 4: Diagnóstico Empírico del Fallo de Visión y Resolución de Bloqueos

Las pruebas de depuración en vivo e inspección forense de la base de datos de Vixl (`vixl.sqlite`), LiteLLM y Ollama revelaron las causas exactas por las que la herramienta `analyze_local_image` provocaba que Vixl se quedara esperando o finalizara en blanco:

### 5.1. Causa Raíz 1: El Servidor MCP `local-vision` Nunca Arrancó (`uvx` Inexistente)
* En `C:\Users\lenin\.vixl\mcp.json`, el servidor `local-vision` estaba configurado con `command: "uvx"`.
* En el sistema operativo Windows 11 del host, el ejecutable `uvx.exe` **no está instalado ni existe en el PATH**.
* Por lo tanto, el proceso del servidor MCP falló de inmediato con error `ENOENT` y la herramienta `analyze_local_image` **nunca llegó a registrarse** en el catálogo de herramientas de Vixl.

### 5.2. Causa Raíz 2: Descarte Silencioso de Herramientas No Registradas en Vixl
* Al enviar el prompt solicitando explícitamente usar `analyze_local_image`, el modelo `qwen3:8b-agent` obedeció a través de LiteLLM y generó una llamada estructurada válida:
  `analyze_local_image({"image_path": "...", "question": "..."})` con `finish_reason: "tool_calls"`.
* Sin embargo, cuando la interfaz Vixl recibió este `tool_calls`, buscó en su registro interno y **no encontró ninguna función asociada** a `analyze_local_image`.
* Al carecer de un manejador válido, el motor de ejecución agéntica de Vixl abortó el ciclo de forma silenciosa (registrado en la tabla `chat_messages` con `parts_json: []` y `finish: "stop"`), dejando la interfaz visual colgada o vacía sin emitir advertencia al usuario.

### 5.3. Causa Raíz 3: Inviabilidad de Doble Modelo 8B en 8 GB de VRAM (Swapping y Timeouts)
* Se ejecutó una prueba de inferencia directa enviando la imagen en Base64 al endpoint `/api/generate` de Ollama con el modelo `qwen3-vl:8b-instruct`.
* **Resultado funcional:** El modelo respondió exitosamente con una descripción detallada y precisa de la geometría 3D y gradientes azules del logo.
* **Métricas de Rendimiento:**
  - Tiempo de inferencia: **54.90 segundos**.
  - Consumo de memoria VRAM: **6,535 MiB** de los 8,188 MiB disponibles en la NVIDIA GeForce RTX 4060.
* **El Cuello de Botella de Arquitectura:**
  - `qwen3:8b-agent` ocupa ~5,600 MiB de VRAM.
  - `qwen3-vl:8b-instruct` ocupa 6,535 MiB de VRAM.
  - Cargar ambos modelos simultáneamente requeriría >12 GB de VRAM, superando la capacidad física de 8 GB.
  - Como consecuencia, Ollama debe desalojar el agente a RAM de sistema, cargar el modelo de visión a GPU (15s), generar la respuesta (55s) y luego recargar el agente a GPU (15s). Este ciclo de swapping de ~85 segundos excede los límites de timeout estándar de Vixl y los clientes MCP (fijados habitualmente entre 30 y 60 segundos).

---

## 6. Resolución de Integración: FastMCP Nativo y Mecanismo `call_mcp_tool` en Vixl

Para sortear las limitaciones de `uvx` y registrar con éxito las herramientas en Vixl, se implementaron dos ajustes técnicos cruciales:

### 6.1. Creación del Servidor FastMCP Nativo en Python
Se implementó un script autocontenido en Python puro: `C:\Users\lenin\Documents\AIDevelopment\ollama\mcp-local-vision\server.py`:
* **Runtime:** Entorno virtual dedicado con `fastmcp==2.12.2` y `httpx`.
* **Configuración en Vixl (`Settings → MCP → local-vision`):**
  - **Transport:** `stdio`
  - **Command:** `C:\Users\lenin\Documents\AIDevelopment\ollama\qwen3-8b-8k\litellm-env\Scripts\python.exe`
  - **Args:** `C:\Users\lenin\Documents\AIDevelopment\ollama\mcp-local-vision\server.py`
  - **Variables de Entorno:** `VISION_MODEL=qwen3-vl:8b-instruct` y `VISION_OLLAMA_HOST=http://127.0.0.1:11434`.

### 6.2. Invocación Canónica en Vixl mediante `call_mcp_tool`
A diferencia de otros clientes MCP que aplanan las herramientas como funciones de primer nivel, **Vixl encapsula todos los servidores MCP externos bajo una única meta-herramienta nativa**: `call_mcp_tool`.
* **Firma de Invocación:**
  ```json
  {
    "serverId": "local-vision",
    "toolName": "analyze_local_image",
    "args": {
      "file_path": "C:\\Users\\lenin\\Documents\\Images\\Logos\\Microsoft_Azure.svg.png",
      "question": "Describe detalladamente el logo, incluyendo su forma, colores y cualquier texto visible."
    }
  }
  ```
* **Aprobación de Permisos en UI:** Toda herramienta MCP requiere autorización explícita del usuario en la interfaz visual de Vixl (`Allow once` o `Always Allow`).

---

## 7. Validación End-to-End y Diagnóstico de Alucinaciones Semánticas

Al ejecutar la invocación con `call_mcp_tool` y autorizar el permiso permanente ("Always Allow"), el flujo operó de principio a fin sin bloqueos ni errores de protocolo:
1. Vixl solicitó confirmación y ejecutó `call_mcp_tool`.
2. El servidor FastMCP en Python leyó el archivo local, codificó en Base64 e invocó Ollama (`qwen3-vl:8b-instruct`).
3. El modelo de visión respondió en ~50 segundos.
4. Vixl recibió la respuesta completa y la renderizó en la interfaz de chat.

### El Hallazgo Crítico: Alucinación Semántica de 8B
Aunque la detección visual de bajo nivel fue impecable (reconoció la letra "A", la forma 3D y los tonos azul marino y cian), el modelo concluyó erróneamente que era el logo de **Adobe**, asociando la "A" estilizada con software creativo en lugar de correlacionar el nombre del archivo (`Microsoft_Azure.svg.png`) y la paleta cromática de Azure. Solo rectificó tras ser confrontado por el usuario en el chat.

Para un análisis detallado sobre el impacto de esta alucinación en entornos autónomos no supervisados, consultar el artículo complementario:
👉 [Límites de Modelos VLM Locales (8B) y Riesgos en Harnesses Autónomos](../concepts/local-vlm-hallucinations-and-autonomous-harness-limits.md).

---

## 8. Soluciones y Arquitectura Recomendada para Visión Local

1. **Reemplazo de uvx por Python Nativo:** Crear un script FastMCP autocontenido ejecutado directamente por el entorno virtual de Python (`python.exe vision_server.py`) en lugar de depender de `uvx`.
2. **Uso de un VLM Ultraligero (2B en lugar de 8B):**
   - En lugar de `qwen3-vl:8b` (6.5 GB), utilizar modelos de visión compactos como **`moondream2`** (~1.8 GB VRAM) o **`minicpm-v`** (~2.5 GB VRAM).
   - Un modelo de 2 GB permite que coexista en memoria o se cargue en menos de 3 segundos, reduciendo el tiempo total de inferencia a menos de 8 segundos y evitando cualquier riesgo de timeout.
3. **Alternativa Multimodal Nativa:** Utilizar un único modelo unificado que sea multimodal y soporte tanto texto/herramientas como visión en un solo peso (ejemplo: `llama3.2-vision:11b` cuando haya más VRAM o quantizaciones reducidas).

---

## 9. Buenas Prácticas y Lecciones Aprendidas

1. **Ruta Real de Configuración de Vixl:** Vixl lee de forma primaria `C:\Users\lenin\.vix\` (sin 'l' final) para `providers.json`, mientras que las sesiones, LSPs y extensiones residen en `~/.vixl/`.
2. **Mínimo de Contexto para Agentes:** Los modelos de 8K tokens no son viables para agentes con múltiples herramientas MCP. Se requiere un mínimo de **16,384 tokens** (`num_ctx 16384`) para dar espacio a los esquemas JSON de las funciones.
3. **Gobierno del Razonamiento en Qwen3:** Los modelos de la familia Qwen3 requieren el parámetro `reasoning_effort: "none"` en peticiones de API o el comando de sistema `/no_think` en su Modelfile para operar como agentes de herramientas directas.
4. **Utilidad de los Proxies de Protocolo:** LiteLLM permite corregir diferencias de especificación entre interfaces agénticas y motores locales sin alterar el código fuente de ninguna de las herramientas.
5. **Verificación de Binarios en Windows:** Todo comando en `mcp.json` debe comprobarse previamente en la consola del sistema (`where.exe <comando>`) para garantizar que el runtime del host pueda invocarlo sin errores `ENOENT`.
