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
9. **Evaluación PaaS Gratuito y Ajuste UI Login:** Análisis comparativo de Koyeb, Zeabur y Render. Selección de Render como solución 100% gratuita (750 horas mensuales sin tarjeta requerida y suspensión automática a los 15 min). Incorporación de selector de URL del Cloud Relay en `/login/` para resolver bloqueos por Mixed Content y creación de `render.yaml` Blueprint.
