---
type: entity
title: "Nodo Workstation: Laptop Windows 11"
description: "Estación de trabajo principal para desarrollo agéntico con Antigravity IDE, Ollama y consola de control"
tags: [workstation, windows11, antigravity-ide, ollama, wsl2]
created: 2026-11-22
updated: 2026-11-22
---

# Nodo Workstation: Laptop Windows 11 (`windows-laptop-node`)

## 1. Identificación y Rol

* **Sistema Operativo:** Windows 11 Pro con subsistema WSL 2 (Ubuntu 20.04 LTS).
* **Entorno de Desarrollo:** Antigravity IDE (agente AI integrado con servidores MCP y LLM Wiki).
* **Motor de Inferencia Local:** Ollama Desktop para modelos locales de asistencia (`qwen3:8b-8k`, `gemma4`).
* **Propósito:** Estación de trabajo para el programador. Proporciona los periféricos físicos (pantalla, teclado y ratón) para administrar el servidor HP ProLiant a través de la red local.

## 2. Conectividad con el Servidor

* Conexión vía WiFi hacia el punto de acceso / repetidor compartido con el servidor.
* Sesiones de terminal OpenSSH y visualización del panel web de Cockpit en navegador.
* Gestión de repositorios en GitHub mediante `gh` CLI y flujos CI/CD.
