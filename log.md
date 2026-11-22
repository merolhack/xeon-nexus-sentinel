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
