# Xeon-Nexus-Sentinel 🛡️⚡

> Panel de control Next.js en GitHub Pages para monitoreo y administración de un servidor HP ProLiant Xeon con AlmaLinux en modo headless, inferencia de IA local (Ollama/llama.cpp), criptominería CPU y microservicios REST en Python sobre plataformas SaaS gratuitas, con memoria de proyecto compilada bajo el estándar Google OKF v0.2 y el patrón Karpathy LLM Wiki.

[![GitHub Pages Deployment](https://github.com/merolhack/xeon-nexus-sentinel/actions/workflows/deploy.yml/badge.svg)](https://github.com/merolhack/xeon-nexus-sentinel/actions/workflows/deploy.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Google OKF v0.2](https://img.shields.io/badge/Memory-Google%20OKF%20v0.2-emerald)](SPEC.md)
[![LLM Wiki](https://img.shields.io/badge/Architecture-Karpathy%20LLM%20Wiki-orange)](index.md)

---

## 📑 Tabla de Contenidos

1. [Visión General y Arquitectura](#visión-general-y-arquitectura)
2. [Matriz de Componentes del Ecosistema](#matriz-de-componentes-del-ecosistema)
3. [Guía de Configuración Headless del Servidor HP ProLiant](#guía-de-configuración-headless-del-servidor-hp-proliant)
4. [Despliegue del Cloud Relay API (PaaS Gratuito)](#despliegue-del-cloud-relay-api-paas-gratuito)
5. [Frontend Next.js y Publicación en GitHub Pages](#frontend-nextjs-y-publicación-en-github-pages)
6. [Memoria Agéntica y Reglas Operativas (OKF v0.2)](#memoria-agéntica-y-reglas-operativas-okf-v02)
7. [Licencia](#licencia)

---

## 1. Visión General y Arquitectura

El ecosistema **Xeon-Nexus-Sentinel** resuelve el desafío de operar y supervisar infraestructura de servidores empresariales legados en un entorno doméstico o de laboratorio, sin incurrir en costos de suscripción en la nube ni requerir monitores, teclados o periféricos dedicados para el servidor.

```text
┌────────────────────────────────────────────────────────────────────────┐
│                        Navegador Web / Celular                         │
│             Frontend Dashboard Next.js (GitHub Pages CDN)              │
│       https://merolhack.github.io/xeon-nexus-sentinel/                 │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │  1. GET /api/telemetry/latest
                                    │     (Bearer JWT)
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                     Cloud Relay API (FastAPI)                          │
│               Koyeb / Zeabur / Render (Cero Costo)                     │
│               Buffer Circular en Memoria RAM (<70 MB)                  │
└───────────────────────────────────▲────────────────────────────────────┘
                                    │  2. POST /api/telemetry
                                    │     (X-Server-Token)
                                    │
┌───────────────────────────────────┴────────────────────────────────────┐
│                    Red Doméstica Privada (LAN / WiFi)                  │
│                                                                        │
│   ┌────────────────────────────────┐   ┌───────────────────────────┐   │
│   │   Laptop Windows 11            │   │   HP ProLiant ML150 G6    │   │
│   │   - Antigravity IDE            │◄──┼───┤   - AlmaLinux 9 Minimal   │   │
│   │   - Ollama Local (Qwen3 /      │SSH│   │   - Xeon LGA1366          │   │
│   │     Gemma4)                    │iLO│   │   - Daemon xeon-sentinel  │   │
│   │   - Consola y Terminal         │Web│   │   - Gobernador IA/Minería │   │
│   └────────────────────────────────┘   └───────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Matriz de Componentes del Ecosistema

| Componente | Directorio | Plataforma / Entorno | Rol Principal |
| :--- | :--- | :--- | :--- |
| **Frontend Dashboard** | `dashboard/` | GitHub Pages | Interfaz estática exportada (`output: 'export'`) con gráficas en tiempo real y autenticación Web Crypto API |
| **Cloud Relay API** | `cloud-relay/` | Koyeb / Zeabur / Render | API REST en Python (FastAPI) que almacena telemetría en memoria volátil y emite tokens JWT |
| **Agente de Telemetría** | `server/` | AlmaLinux 9 (HP ProLiant) | Daemon en Python que recopila métricas de CPU, RAM, temperatura, IA y minería, y las envía al Relay |
| **Gobernador de Recursos** | `server/scripts/` | AlmaLinux 9 (HP ProLiant) | Script en bash que vigila el puerto de inferencia de IA y pausa XMRig para evitar saturar el bus de memoria |
| **Memoria Agéntica** | `wiki/`, `raw/` | Repositorio Git | Base de conocimiento compilada bajo Google OKF v0.2 y sincronizada con Gemini Notebook |

---

## 3. Guía de Configuración Headless del Servidor HP ProLiant

El servidor HP ProLiant carece de periféricos de entrada y salida propios. La administración se centraliza utilizando la laptop con Windows 11.

### 3.1. Conexión de Red Físico y Topología
* **Opción Recomendada (Repetidor WiFi):**
  - Conectar el cable Ethernet 1 a la tarjeta de red Gigabit integrada (tráfico de AlmaLinux 9).
  - Conectar el cable Ethernet 2 al puerto de gestión remota **HP iLO 100i (BMC)**.
  - La laptop se conecta vía WiFi en la misma subred.
* **Diagnóstico Inicial (BIOS / POST):**
  - Para visualizar el arranque inicial antes de tener IP, conectar un convertidor activo de VGA macho a HDMI hembra (alimentado por USB 5V) a cualquier monitor externo.

### 3.2. Acceso Administrativo
1. **HP iLO 100i:** Abrir el navegador en Windows e ingresar a la dirección IP asignada al BMC por DHCP. Permite encender o reiniciar la máquina en frío.
2. **OpenSSH:** Conectarse desde PowerShell o Windows Terminal:
   ```bash
   ssh -i ~/.ssh/id_ed25519 admin@192.168.1.150
   ```
3. **Consola Web Cockpit (Puerto 9090):**
   - Habilitar el servicio en AlmaLinux:
     ```bash
     sudo systemctl enable --now cockpit.socket
     ```
   - Ingresar en el navegador a `https://192.168.1.150:9090` para gestionar almacenamiento, terminal y servicios.

### 3.3. Instalación del Agente de Telemetría
```bash
# En el servidor AlmaLinux 9:
sudo mkdir -p /opt/xeon-sentinel
sudo cp server/daemon/* /opt/xeon-sentinel/
sudo pip3 install -r /opt/xeon-sentinel/requirements.txt
sudo cp server/systemd/xeon-sentinel.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now xeon-sentinel.service
```

---

## 4. Despliegue del Cloud Relay API (PaaS Gratuito)

El microservicio `cloud-relay/` puede desplegarse en cualquier servicio que soporte Docker o Python 3.12:

### Variables de Entorno Requeridas:
* `ADMIN_USER`: Nombre del usuario administrador (ej. `admin`).
* `ADMIN_PASSWORD_HASH`: Hash SHA-256 de la contraseña (por defecto: `xeonsentinel2026`).
* `JWT_SECRET_KEY`: Cadena aleatoria segura para firmar los tokens JWT.
* `SERVER_INGEST_TOKEN`: Token precompartido que el servidor AlmaLinux envía en `X-Server-Token`.

### Despliegue Rápido en Koyeb / Zeabur / Render:
1. Conectar este repositorio a tu cuenta de Koyeb o Zeabur.
2. Configurar el directorio raíz de construcción como `cloud-relay/` (o seleccionar Dockerfile).
3. Añadir las variables de entorno indicadas arriba.
4. El servicio quedará disponible en una URL HTTPS pública (ej. `https://tu-relay.koyeb.app`).

---

## 5. Frontend Next.js y Publicación en GitHub Pages

El frontend está ubicado en `dashboard/` y se compila como un sitio estático puro (`output: 'export'`).

### Flujo de Trabajo Local:
```bash
cd dashboard
npm install
npm run dev
```

### Publicación Automatizada:
El workflow de GitHub Actions en `.github/workflows/deploy.yml` compila y publica automáticamente la aplicación en la rama `gh-pages` ante cada `push` a la rama `main`.

Asegúrate de habilitar GitHub Pages en el repositorio:
`Settings → Pages → Source: Deploy from a branch / gh-pages` o `GitHub Actions`.

---

## 6. Memoria Agéntica y Reglas Operativas (OKF v0.2)

Este proyecto cuenta con una memoria viva de tres capas según el estándar **Google OKF v0.2**:
- `raw/`: Fichas técnicas inmutables de procesadores Xeon, HP ProLiant y límites de servicios cloud.
- `wiki/`: Artículos modulares organizados en `systems/`, `concepts/` y `entities/`.
- `AGENTS.md`: Manual operativo de cumplimiento obligatorio para agentes de IA.

### Sincronización con Gemini Notebook:
El proyecto está conectado al cuaderno de Gemini Notebook:
`https://notebook.google.com/notebook/1bd607be-628c-4228-a1f5-5b4f5dd59093`

Para compilar y sincronizar la base de conocimiento:
```bash
npm run wiki:sync-notebook
```

---

## 7. Licencia

Distribuido bajo la Licencia **MIT**. Consulta el archivo `LICENSE` para más detalles.
