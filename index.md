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
