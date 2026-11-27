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
* [local-autonomous-agent-stack-vixl-litellm.md](file:///wiki/systems/local-autonomous-agent-stack-vixl-litellm.md) — Stack de agente autónomo local con Vixl IDE, LiteLLM Proxy, Ollama y servidores MCP.
* [hybrid-cloud-inference-nvidia-nim.md](file:///wiki/systems/hybrid-cloud-inference-nvidia-nim.md) — Topología de inferencia híbrida con NVIDIA NIM, Moonshot Kimi K3 Pro (1M contexto) y LiteLLM Proxy.

### 2. Conceptos y Protocolos de Ingeniería (`wiki/concepts/`)
* [cpu-inference-tuning.md](file:///wiki/concepts/cpu-inference-tuning.md) — Optimización de inferencia cuantizada (GGUF Q4_K_M) en arquitecturas Intel Xeon legadas sin AVX2.
* [randomx-cache-isolation.md](file:///wiki/concepts/randomx-cache-isolation.md) — Regla de afinidad y memoria caché L3 (2 MB por hilo) para minería RandomX y gobernanza con IA.
* [static-client-auth.md](file:///wiki/concepts/static-client-auth.md) — Esquema de autenticación criptográfica en el cliente mediante Web Crypto API y tokens JWT.
* [secrets-management-and-gitguardian.md](file:///wiki/concepts/secrets-management-and-gitguardian.md) — Gestión segura de credenciales, política de cero secretos y validación con GitGuardian y pre-commit hooks.
* [storage-optimization-and-gdrive-backup.md](file:///wiki/concepts/storage-optimization-and-gdrive-backup.md) — Optimización de disco local (Windows 11 / WSL2) y respaldos seguros en Google Drive con rclone (5 TiB).
* [execution-timeouts-and-anti-hang-patterns.md](file:///wiki/concepts/execution-timeouts-and-anti-hang-patterns.md) — Políticas estrictas de timeout y patrones anti-bloqueo en comandos de red y diagnóstico del agente.
* [strata-vs-ollama-inference.md](file:///wiki/concepts/strata-vs-ollama-inference.md) — Análisis arquitectónico de Strata Frameworks (MoE Qwen3.8/GLM), jerarquía de memoria y viabilidad frente a Ollama en CPU Xeon Nehalem.
* [server-memory-and-bios-governance.md](file:///wiki/concepts/server-memory-and-bios-governance.md) — Gobernanza de memoria DDR3 ECC (RDIMM vs UDIMM), reglas de coexistencia y configuración de arranque en BIOS y Smart Array P410.
* [headless-boot-diagnostics-and-telemetry.md](file:///wiki/concepts/headless-boot-diagnostics-and-telemetry.md) — Diagnóstico de arranque sin monitor, telemetría de capa física PHY (100M/1G) y automatización de inicio iPXE (sanboot).
* [local-vlm-hallucinations-and-autonomous-harness-limits.md](file:///wiki/concepts/local-vlm-hallucinations-and-autonomous-harness-limits.md) — Límites de modelos VLM locales (8B), riesgos en harnesses autónomos y la paradoja de la verificación humana.

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
- [Guía de Expansión de Hardware, Despliegue de LLMs SSE4.2 y Orquestación Cripto](wiki/concepts/hardware-upgrades-and-crypto-orchestration.md)
- [Nodo de Trabajo: Laptop THUNDEROBOT ZERO](wiki/entities/thunderobot-laptop-node.md)
- [Arquitectura Híbrida: Laptop RTX 4060 + Servidor HP 24/7](wiki/concepts/hybrid-ai-and-crypto-synergy.md)
- [Topología de Red Autónoma: Repetidor AC1200 y Multi-ISP](wiki/systems/dual-wan-and-repeater-network-topology.md)
- [Stack de Agente Autónomo Local: Vixl, LiteLLM y Ollama](wiki/systems/local-autonomous-agent-stack-vixl-litellm.md)
