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

## 5. Fase 4: Diagnóstico de Estado y Resolución de Bloqueos

Las pruebas con `--detailed_debug` en LiteLLM confirman que la comunicación HTTP entre Vixl, LiteLLM y Ollama opera con código `HTTP 200 OK`. Sin embargo, se identificó un comportamiento de espera infinita en Vixl al invocar ciertas herramientas:

### Causas Raíz Diagnosticadas:
1. **Discrepancia en `finish_reason`:** En respuestas de herramientas, algunos proxies devuelven `finish_reason: "stop"` en lugar de `finish_reason: "tool_calls"`. Cuando Vixl no detecta la señal explícita de invocación de herramienta, no procesa el payload y permanece en estado de carga.
2. **Saturación del Contexto por Esquemas MCP:** El registro simultáneo de 4 servidores MCP con esquemas JSON detallados consume hasta el 76% de la ventana de contexto de 16K antes de que el usuario envíe su primer mensaje, dejando poco margen para el prompt y el historial.

### Protocolo de Mitigación y Próximos Pasos:
* **Aislamiento por Herramienta:** Probar primero con herramientas ligeras (ej. `web-search` o `filesystem`) antes de invocar herramientas pesadas como `local-vision`.
* **Auditoría de Payload:** Capturar el JSON exacto de respuesta de LiteLLM para confirmar que `tool_calls` esté correctamente formateado.
* **Monitoreo de Contexto:** Reducir o modularizar el número de herramientas activas por sesión para evitar que los esquemas saturen el 70%+ de la ventana de contexto.

---

## 6. Buenas Prácticas y Lecciones Aprendidas

1. **Ruta Real de Configuración de Vixl:** Vixl lee de forma primaria `C:\Users\lenin\.vix\` (sin 'l' final) para `providers.json`, mientras que las sesiones, LSPs y extensiones residen en `~/.vixl/`.
2. **Mínimo de Contexto para Agentes:** Los modelos de 8K tokens no son viables para agentes con múltiples herramientas MCP. Se requiere un mínimo de **16,384 tokens** (`num_ctx 16384`) para dar espacio a los esquemas JSON de las funciones.
3. **Gobierno del Razonamiento en Qwen3:** Los modelos de la familia Qwen3 requieren el parámetro `reasoning_effort: "none"` en peticiones de API o el comando de sistema `/no_think` en su Modelfile para operar como agentes de herramientas directas.
4. **Utilidad de los Proxies de Protocolo:** LiteLLM permite corregir diferencias de especificación entre interfaces agénticas y motores locales sin alterar el código fuente de ninguna de las herramientas.
