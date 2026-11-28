# AGENTS.md — Manual Operativo y Directivas de Ingeniería para Agentes de IA

Este documento establece las **reglas estrictas y de cumplimiento obligatorio** para cualquier agente de Inteligencia Artificial (Antigravity IDE, Gemini CLI, Claude, subagentes) o desarrollador que interactúe, genere o modifique código en el repositorio `merolhack/xeon-nexus-sentinel`.

---

## 1. Reglas Estrictas y Mandatos Inmutables

> [!IMPORTANT]
> **MANDATOS OBLIGATORIOS (PRIORIDAD CRÍTICA):**
>
> 1. **Gobernanza Dual de Inferencia Secundaria (`ollama-local` vs `nvidia-nim`):**
>    - El agente DEBE utilizar siempre ambos servidores MCP dependiendo estrictamente del caso de uso:
>      * **`ollama-local` (`consultar_modelo_local`):** Es la salvaguarda obligatoria para cuando se esté **offline (sin conexión a internet)** o cuando se procesen **secretos, credenciales, tokens y claves privadas** que nunca deben salir de la máquina local. Consulta primero `gemma4:cloud` si hay cuota y cae automáticamente al modelo local `qwen3:8b-8k`. Queda estrictamente prohibido intentar invocar comandos interactivos en consola (`ollama run`) que bloqueen la terminal.
>      * **`nvidia-nim` (`consultar_modelo_nvidia` y `analizar_imagen_nvidia`):** Se DEBE utilizar de forma prioritaria para tareas complejas, visión multimodal, razonamiento y consultas técnicas en la nube. Ofrece respuestas más del doble de rápidas (~2s a 4s), sin consumir memoria de la tarjeta gráfica (0 MB VRAM local) y con un criterio técnico superior que evita alucinaciones sobre precios, cuotas y compatibilidades en la nube. Incluye `moonshotai/kimi-k3.1-pro` (1M tokens de contexto masivo y arquitectura) y `nvidia/nemotron-3.5-super-vl-120b` (visión 120B de alta fidelidad).
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
> 4. **Siempre usar y mantener Codebase Memory (Auto-Indexación Obligatoria):**
>    - Este proyecto utiliza `codebase-memory` para mantener un grafo de conocimiento semántico (LSP, rutas, funciones y llamadas).
>    - Usar prioritariamente las herramientas MCP del grafo (`search_graph`, `trace_path`, `get_code_snippet`, `query_graph`, `index_status`) antes de recurrir a búsquedas textuales ciegas (`grep`/`find`).
>    - **Regla estricta de indexación:** El agente DEBE verificar el estado de indexación. **Si el proyecto no está indexado, se DEBE ejecutar inmediatamente `index_repository`.** Asimismo, tras añadir, renombrar o refactorizar archivos de código o servicios, es OBLIGATORIO refrescar el grafo con `index_repository`.
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
1. Consultar LLM Wiki (index.md y wiki/) + Codebase Memory (si no indexado: index_repository; luego search_graph)
       │
       ▼
2. Delegar tareas secundarias: ollama-local (offline/secretos) vs nvidia-nim (visión/código/rápido)
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
