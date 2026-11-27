# Inferencia Híbrida en la Nube con NVIDIA NIM, LiteLLM y Vixl IDE

---
title: Inferencia Híbrida en la Nube con NVIDIA NIM, LiteLLM y Vixl IDE
type: system
tags: [cloud-ai, nvidia-nim, litellm, vixl, moonshot-kimi, nemotron, mcp, hybrid-stack]
created: 2026-11-27
updated: 2026-11-27
status: stable
---

## 1. Resumen Ejecutivo

Para superar las barreras de memoria VRAM (límite de 8 GB en la GPU NVIDIA RTX 4060) y eliminar las alucinaciones semánticas presentes en modelos locales compactos de 8B, se diseñó e implementó una **arquitectura de inferencia híbrida**. 

Esta solución unifica el motor local **Ollama** con el catálogo empresarial gratuito de **NVIDIA NIM (`build.nvidia.com`)** mediante **LiteLLM Proxy** actuando como bus central en el puerto `4000`. La interfaz **Vixl IDE** interactúa de manera transparente con ambos mundos, permitiendo alternar entre privacidad total offline y modelos de frontera en la nube (>100B, 1M de ventana de contexto y VLM nativo) manteniendo la ejecución de herramientas locales mediante **Model Context Protocol (MCP)**.

---

## 2. Topología de la Arquitectura Híbrida

```text
                               ┌────────────────────────────────────────────────────────┐
                               │                    Vixl IDE (Host)                     │
                               │  - Selector de Modelos en Chat (providers.json)        │
                               │  - Servidores MCP locales (filesystem, memory, vision) │
                               └──────────────────────────┬─────────────────────────────┘
                                                          │ HTTP (Chat Completions)
                                                          ▼
                               ┌────────────────────────────────────────────────────────┐
                               │             LiteLLM Proxy (Puerto 4000)                │
                               │           C:\...\litellm-env\config.yaml               │
                               └──────┬───────────────────────────────────┬─────────────┘
                                      │                                   │
                                      ▼                                   ▼
                         [ Ollama Local (11434) ]               [ NVIDIA NIM API Cloud ]
                           - qwen3:8b-agent                       https://integrate.api.nvidia.com/v1
                           - qwen3-vl:8b                          - moonshotai/kimi-k3.1-pro (1M ctx)
                           (100% Privado / Offline)               - nvidia/nemotron-3.5-super-vl-120b
                                                                  - nvidia/nemotron-3.5-lightning-30b
                                                                  (0 GB VRAM local / 40 RPM gratis)
```

---

## 3. Catálogo de Modelos Integrados vía NVIDIA NIM

Al consultar el endpoint `https://integrate.api.nvidia.com/v1/models` con la clave personal `nvapi-...`, se seleccionaron los siguientes modelos de alto rendimiento para el entorno de desarrollo:

1. **`moonshotai/kimi-k3.1-pro` (Kimi K3 Pro):**
   - **Ventana de Contexto:** 1,048,576 tokens (1M tokens).
   - **Capacidades:** Visión multimodal (VLM), soporte nativo de llamadas a herramientas (`tools: true`) y modo de razonamiento estructurado (`thinking: true`).
   - **Caso de uso principal:** Análisis de bases de código completas, lectura de documentos masivos y resolución de problemas arquitectónicos complejos.

2. **`nvidia/nemotron-3.5-super-vl-120b-a12b` (Nemotron Super VL):**
   - **Tamaño:** 120B de parámetros.
   - **Capacidades:** Visión de alta fidelidad, comprensión espacial de capturas de pantalla, diagramas y diseño de interfaces.
   - **Caso de uso principal:** Sustitución de modelos VLM locales de 8B para eliminar alucinaciones en inspección visual sin saturar la VRAM local.

3. **`nvidia/nemotron-3.5-lightning-30b-a3b` (Nemotron Lightning):**
   - **Tamaño:** 30B de parámetros.
   - **Capacidades:** Optimizado para latencia ultrabaja y generación rápida de código.
   - **Caso de uso principal:** Autocompletado, formateo, refactorización y docstrings interactivos.

---

## 4. Implementación y Configuración del Stack

### 4.1. Configuración de LiteLLM (`config.yaml`)
El archivo `C:\Users\lenin\Documents\AIDevelopment\ollama\qwen3-8b-8k\config.yaml` mapea los identificadores amigables hacia los endpoints correspondientes:

```yaml
model_list:
  # Inferencia Local (Ollama)
  - model_name: qwen3-agent-no-think
    litellm_params:
      model: openai/qwen3:8b-agent
      api_base: http://127.0.0.1:11434/v1
      api_key: "ollama"
      reasoning_effort: "none"

  # Inferencia en la Nube (NVIDIA NIM)
  - model_name: kimi-k3-pro-nvidia
    litellm_params:
      model: openai/moonshotai/kimi-k3.1-pro
      api_base: https://integrate.api.nvidia.com/v1
      api_key: "os.environ/NVIDIA_API_KEY"

  - model_name: nemotron-super-vl-nvidia
    litellm_params:
      model: openai/nvidia/nemotron-3.5-super-vl-120b-a12b
      api_base: https://integrate.api.nvidia.com/v1
      api_key: "os.environ/NVIDIA_API_KEY"

  - model_name: nemotron-lightning-nvidia
    litellm_params:
      model: openai/nvidia/nemotron-3.5-lightning-30b-a3b
      api_base: https://integrate.api.nvidia.com/v1
      api_key: "os.environ/NVIDIA_API_KEY"

litellm_settings:
  drop_params: true

general_settings:
  master_key: "sk-litellm-local-key-12345"
```

### 4.2. Registro en Vixl IDE (`providers.json`)
Tanto en `C:\Users\lenin\.vix\providers.json` como en `C:\Users\lenin\.vixl\providers.json`, el proveedor LiteLLM expone la lista completa:

```json
{
  "providers": {
    "litellm": {
      "name": "LiteLLM Proxy",
      "base_url": "http://localhost:4000/v1",
      "wire_api": "chat",
      "models": [
        "qwen3-agent-no-think",
        "kimi-k3-pro-nvidia",
        "nemotron-super-vl-nvidia",
        "nemotron-lightning-nvidia"
      ]
    }
  }
}
```

---

## 5. Desacoplamiento de Inferencia y Ejecución de Herramientas (MCP)

Uno de los mayores beneficios de esta topología es la separación entre el procesamiento del lenguaje y la ejecución en el sistema de archivos:
1. El usuario envía una consulta solicitando leer o editar un archivo local mientras está seleccionado `kimi-k3-pro-nvidia`.
2. El prompt viaja a la nube de NVIDIA donde el modelo de 1M de contexto determina que requiere ejecutar `call_mcp_tool`.
3. Vixl recibe la instrucción en su entorno anfitrión (Windows 11 / WSL2), solicita permiso interactivo (*"Always Allow"*) y corre la herramienta en local (`filesystem`, `memory`, `local-vision`).
4. El resultado se reinyecta al modelo en la nube para generar el análisis final.

Esto permite que un modelo de frontera de 120B o 1M de contexto opere directamente sobre el disco local sin consumir un solo megabyte de VRAM en la GPU de la laptop.

---

## 6. Política de Seguridad y Cero Secretos

Siguiendo el estándar de DevSecOps del proyecto:
* La clave real `NVIDIA_API_KEY=nvapi-...` reside exclusivamente en `.env` (ignorado por `.gitignore`).
* En el repositorio Git únicamente se rastrea `.env.example` con la plantilla pública `NVIDIA_API_KEY=nvapi-tu_clave_personal_de_nvidia_nim`.
* Toda rotación o adición de proveedores en la nube debe cumplir con la validación de GitGuardian antes de ser enviada al control de versiones.
