---
type: system
title: "Daemon de Telemetría en AlmaLinux 9"
description: "Servicio en segundo plano para recolección de métricas de CPU, RAM, temperatura, IA y minería en AlmaLinux 9"
tags: [almalinux, daemon, python, telemetria, systemd]
created: 2026-11-22
updated: 2026-11-22
---

# Daemon de Telemetría en AlmaLinux 9 (`xeon-sentinel`)

## 1. Responsabilidad y Funcionamiento

El daemon de telemetría reside en el servidor HP ProLiant ML150 G6 operando sobre **AlmaLinux 9 Minimal**. Su propósito es inspeccionar el estado del hardware, los procesos de inferencia local (`llama.cpp` o Ollama) y el minero XMRig (RandomX), empaquetando periódicamente un objeto JSON que se despacha vía HTTP POST al Cloud Relay.

## 2. Métricas Recolectadas

1. **CPU y Frecuencia:** Lectura diferencial de `/proc/stat` y `/proc/cpuinfo` calculando el porcentaje de uso por núcleo e integral.
2. **Memoria y NUMA:** Lectura de `/proc/meminfo` (MemTotal, MemFree, Buffers, Cached) y desglose de páginas locales vs remotas vía `numastat`.
3. **Sensores Térmicos:** Extracción mediante `sysfs` (`/sys/class/thermal/` o `coretemp`) o comando IPMI BMC.
4. **Estado de IA Local:** Sonda HTTP hacia el endpoint `/api/tags` o `/api/ps` de Ollama / `llama.cpp` server para medir modelos cargados y tiempos de generación.
5. **Estado de Criptominería:** Consulta al endpoint HTTP local de XMRig (`http://127.0.0.1:18088/1/summary`) extrayendo hashrate a 10s, 60s, 15m y temperatura de encapsulado.

## 3. Configuración y Ejecución

- **Archivo de Configuración:** `server/daemon/config.yaml`
- **Servicio Systemd:** `server/systemd/xeon-sentinel.service`
- **Cadencia de Publicación:** Cada 5 segundos en condiciones normales, con reintentos exponenciales ante fallos de red.
