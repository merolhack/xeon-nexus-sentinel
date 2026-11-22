---
type: concept
title: "Gestión Segura de Credenciales y Validación con GitGuardian"
description: "Estrategias de protección de secretos, aislamiento de contraseñas en hosting estático y uso del nivel gratuito de GitGuardian"
tags: [seguridad, secretos, gitguardian, ggshield, devsecops, jwt]
created: 2026-11-22
updated: 2026-11-22
---

# Gestión Segura de Credenciales y Validación con GitGuardian

## 1. ¿Por Qué las Credenciales NO Quedan Expuestas en GitHub?

### A. Capa Frontend (GitHub Pages)
- El panel de control se compila a JavaScript estático (`output: 'export'`).
- El código en GitHub Pages **no almacena ni incluye la contraseña del administrador**.
- Cuando el usuario ingresa sus datos en `/login/`:
  1. El navegador utiliza la Web Crypto API (`crypto.subtle.digest`) para calcular el hash SHA-256 de la contraseña en la memoria volátil del navegador.
  2. El frontend despacha una petición `POST /api/auth/login` con el usuario y el hash al Cloud Relay.
  3. Ni la contraseña en claro ni las credenciales maestras quedan en el árbol de Git ni en los archivos HTML/JS estáticos.

### B. Capa de Servicios (Cloud Relay en Koyeb / Zeabur / Render)
- El microservicio en Python lee las credenciales exclusivamente desde **variables de entorno del sistema operativo del contenedor**:
  - `ADMIN_USER`
  - `ADMIN_PASSWORD_HASH`
  - `JWT_SECRET_KEY`
  - `SERVER_INGEST_TOKEN`
- Estas variables se definen directamente en la consola web del proveedor cloud (fuera del repositorio) y `.gitignore` bloquea cualquier archivo `.env` o token local.

---

## 2. Implementación Gratuita de GitGuardian

GitGuardian ofrece un plan gratuito permanente (Free Tier) para desarrolladores individuales y proyectos personales (hasta 25 desarrolladores):

### Opción A: GitGuardian GitHub App (Monitoreo en la Nube)
1. Instalar la aplicación gratuita **GitGuardian** desde el GitHub Marketplace:
   `https://github.com/marketplace/gitguardian`
2. Seleccionar el repositorio `merolhack/xeon-nexus-sentinel`.
3. Cada vez que se realiza un `git push` o un Pull Request, los servidores de GitGuardian escanean automáticamente todos los commits. Si se detecta un token o clave privada, el desarrollador recibe una notificación de incidente inmediata.

### Opción B: CLI `ggshield` Local (Shift-Left DevSecOps)
Permite bloquear la creación del commit en la propia máquina antes de que los datos salgan hacia internet:
1. Instalar `ggshield` en el entorno WSL o Windows:
   ```bash
   pip install ggshield
   ```
2. Iniciar sesión con la cuenta gratuita:
   ```bash
   ggshield auth login
   ```
3. Activar el hook pre-commit:
   ```bash
   ggshield install -m repo
   ```
   A partir de ese momento, `ggshield secret scan pre-commit` se ejecutará en cada `git commit`.

### Opción C: Escaneo Nativo Integrado en el Repositorio (`scripts/scan-secrets.sh`)
Para operar de inmediato sin depender de cuentas externas:
- El repositorio incluye [scripts/scan-secrets.sh](file:///wsl.localhost/ubuntu-20.04/home/merolhack/fl/xeon-nexus-sentinel/scripts/scan-secrets.sh) y [.githooks/pre-commit](file:///wsl.localhost/ubuntu-20.04/home/merolhack/fl/xeon-nexus-sentinel/.githooks/pre-commit).
- Verifica mediante expresiones regulares que ningún cambio preparado contenga tokens de GitHub (`ghp_`), AWS (`AKIA...`), claves privadas SSH/RSA (`BEGIN PRIVATE KEY`) o tokens JWT.
- Activar los hooks compartidos con:
  ```bash
  git config core.hooksPath .githooks
  ```
