---
type: system
title: "Cloud Relay API en Python (FastAPI)"
description: "Microservicio REST intermediario para ingesta y distribución de telemetría en nubes SaaS gratuitas"
tags: [fastapi, python, cloud-relay, koyeb, zeabur, render, jwt]
created: 2026-11-22
updated: 2026-11-22
---

# Cloud Relay API en Python (`cloud-relay`)

## 1. Propósito de la Capa de Intermediación

Debido a que el servidor HP ProLiant se encuentra tras una conexión de banda ancha residencial (NAT de doble capa o Carrier-Grade NAT sin IP pública fija) y el frontend se ejecuta como archivos estáticos en GitHub Pages, el **Cloud Relay** actúa como puente público seguro de baja latencia.

## 2. Endpoints Expuestos

| Método | Ruta | Autenticación | Función |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/telemetry` | Encabezado `X-Server-Token` | Recibe payload JSON del daemon en AlmaLinux y lo almacena en RAM circular |
| `GET` | `/api/telemetry/latest` | `Bearer <JWT_TOKEN>` | Devuelve la instantánea más reciente de métricas al frontend |
| `GET` | `/api/telemetry/history` | `Bearer <JWT_TOKEN>` | Devuelve una serie temporal con las últimas 100 muestras |
| `POST` | `/api/auth/login` | Público (Body JSON) | Valida usuario y contraseña cifrada emitiendo un JWT firmado |
| `GET` | `/api/health` | Público | Comprobación de estado para keep-alive y monitorización de uptime |

## 3. Aislamiento y Memoria Volátil

- El servicio mantiene un buffer circular `deque(maxlen=100)` en memoria volátil de Python.
- No utiliza bases de datos externas como PostgreSQL o Redis, garantizando un consumo de RAM inferior a 70 MB y adaptándose al nivel gratuito de Koyeb, Zeabur o Render.
