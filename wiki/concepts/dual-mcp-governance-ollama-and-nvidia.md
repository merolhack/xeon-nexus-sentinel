# Gobernanza Dual de Inferencia Secundaria (Ollama Local vs NVIDIA NIM) e Indexación de Código

---
title: Gobernanza Dual de Inferencia Secundaria (Ollama Local vs NVIDIA NIM) e Indexación de Código
type: concept
tags: [governance, mcp, ollama, nvidia-nim, codebase-memory, graph-indexing, security]
created: 2026-11-27
updated: 2026-11-27
status: stable
---

## 1. Resumen Ejecutivo

En el desarrollo de software agéntico dentro de **Antigravity IDE**, la delegación de tareas a modelos secundarios debe equilibrar tres factores críticos: **privacidad absoluta de datos**, **velocidad de inferencia** y **fidelidad técnica (cero alucinaciones)**.

Este documento formaliza la directiva operativa de **gobernanza dual de servidores MCP** implementada en el repositorio `xeon-nexus-sentinel`. Establece los límites y casos de uso estrictos para alternar entre el servidor local **`ollama-local`** y el servidor cloud **`nvidia-nim`**, así como el mandato imperativo de indexación continua del grafo semántico mediante **`codebase-memory`**.

---

## 2. Los Dos Servidores MCP y sus Roles Operativos

```text
                                 [ Agente Antigravity IDE ]
                                             │
                       ┌─────────────────────┴─────────────────────┐
                       ▼                                           ▼
             [ Caso: Offline / Privado ]                 [ Caso: Cloud / Visión / 1M ]
                       │                                           │
                       ▼                                           ▼
             [ MCP: ollama-local ]                       [ MCP: nvidia-nim ]
             - Motor: Qwen3 8B / Gemma4                  - Motor: Nemotron / Kimi K3.1
             - Latencia: ~30s (local)                    - Latencia: ~2s a 4s (cloud)
             - Consumo VRAM: 5.6 GB local                - Consumo VRAM: 0 MB local
             - Fugas: 0% (Air-gapped)                    - Precisión: Alta (cero alucinación)
```

### 2.1. Servidor MCP `ollama-local` (Salvaguarda Offline y Máxima Privacidad)
* **Herramienta:** `consultar_modelo_local(prompt: str)`
* **Mecanismo:** Intenta primero `gemma4:cloud` si la cuota semanal está disponible (< 90%); en caso de fallo o saturación, cae automáticamente al modelo local `qwen3:8b-8k` en `http://localhost:11434`.
* **Casos de Uso Obligatorios:**
  1. **Operación Offline:** Cuando la máquina no dispone de conexión a internet o se trabaja en redes restringidas.
  2. **Procesamiento de Secretos y Credenciales:** Análisis de archivos de entorno (`.env`), claves privadas SSH, tokens JWT, hashes criptográficos o información fiscal que bajo ninguna circunstancia debe salir de la máquina local.
  3. **Lógica de Dominio Confidencial:** Código propietario o propiedad intelectual sensible.

### 2.2. Servidor MCP `nvidia-nim` (Alto Rendimiento, Visión y Contexto Masivo)
* **Herramientas:** `consultar_modelo_nvidia(prompt: str, modelo: str)` y `analizar_imagen_nvidia(image_path: str, question: str)`
* **Mecanismo:** Conexión HTTPS segura directa al endpoint `https://integrate.api.nvidia.com/v1` consumiendo modelos empresariales mediante `NVIDIA_API_KEY`.
* **Casos de Uso Obligatorios:**
  1. **Velocidad y Eficiencia:** Respuestas más del doble de rápidas (~2 a 4 segundos frente a ~30 segundos en local), liberando la GPU RTX 4060 (0 MB de VRAM consumida).
  2. **Criterio Técnico y Factual:** Evita alucinaciones sobre arquitecturas complejas, límites de cuotas de APIs en la nube y modelos de tarificación (donde modelos locales pequeños suelen equivocarse).
  3. **Visión Multimodal de Alta Fidelidad:** Análisis de capturas de pantalla, diagramas de arquitectura y mockups mediante **Nemotron Super VL (120B)**, erradicando los falsos reconocimientos morfológicos de los VLMs de 8B.
  4. **Ventanas de Contexto Masivas:** Procesamiento de bases de código completas o volcados de logs extensos mediante **Moonshot Kimi K3.1 Pro (1,048,576 tokens de contexto)**.

---

## 3. Matriz de Decisión para Agentes de IA

| Escenario / Tarea | Servidor MCP Obligatorio | Razón Técnica |
| :--- | :--- | :--- |
| **Auditoría de `.env` o credenciales** | `ollama-local` | Garantía de aislamiento total (Cero fugas). |
| **Generación de docstrings y formatters offline** | `ollama-local` | Operación autónoma sin dependencia de red. |
| **Análisis de capturas de pantalla / UI** | `nvidia-nim` | Nemotron 120B evita alucinaciones visuales. |
| **Consultas sobre APIs Cloud, cuotas y límites** | `nvidia-nim` | Razonamiento estricto y factual sin inventar datos. |
| **Refactorización de archivos de más de 10K tokens** | `nvidia-nim` (Kimi) | Ventana de contexto masiva de 1 Millón de tokens. |
| **Consultas rápidas de código durante el flujo** | `nvidia-nim` (Lightning) | Inferencia ultra-rápida (~2 segundos). |

---

## 4. Mandato Estricto de Codebase Memory (Auto-Indexación)

El grafo de conocimiento de código (`codebase-memory`) es la fuente primaria de verdad para navegación arquitectónica, superando el escaneo ciego por texto plano (`grep` o `find`).

### 4.1. Verificación Previa Obligatoria
Antes de iniciar cualquier exploración estructural en el repositorio:
1. El agente debe verificar si el proyecto está registrado e indexado (`list_projects` / `index_status`).
2. **Si el proyecto no está indexado:** Es MANDATORIO invocar `index_repository` antes de responder o realizar cambios de código.
3. **Tras cambios en código:** Al añadir, renombrar o refactorizar archivos, es obligatorio ejecutar `index_repository` para refrescar nodos y aristas (LSP, llamadas y tipos).

### 4.2. Jerarquía de Descubrimiento de Código
1. `search_graph` — Búsqueda de clases, métodos, endpoints y variables por patrón regex.
2. `trace_path` — Trazado de llamadas entrantes (*inbound*) o salientes (*outbound*).
3. `get_code_snippet` — Lectura de la definición exacta de un símbolo.
4. `detect_changes` — Impacto semántico de archivos modificados respecto a HEAD.
5. `grep`/`read_file` — Únicamente como fallback para literales de texto, scripts shell o configuraciones no analizadas por LSP.
