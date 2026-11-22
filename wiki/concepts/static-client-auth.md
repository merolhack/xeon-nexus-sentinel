---
type: concept
title: "Autenticación Criptográfica para Clientes Estáticos"
description: "Esquema de autenticación sin backend dinámico en hosting estático mediante Web Crypto API y tokens JWT"
tags: [seguridad, web-crypto-api, jwt, static-auth, sha256]
created: 2026-11-22
updated: 2026-11-22
---

# Autenticación Criptográfica para Clientes Estáticos

## 1. El Reto del Hosting Estático en GitHub Pages

GitHub Pages distribuye contenido exclusivamente estático (HTML, CSS y JS compilados). No existe un servidor Node.js o PHP intermedio para gestionar sesiones con cookies seguras `HttpOnly` originadas en el mismo dominio.

## 2. Flujo de Autenticación Criptográfica

Para permitir la visualización privada de métricas:

1. **Ingreso en el Cliente:** El usuario introduce su nombre de usuario y contraseña en la página `/login/`.
2. **Pre-hashing con Web Crypto API:** El navegador calcula un hash SHA-256 de la contraseña utilizando la API nativa `crypto.subtle.digest`. Nunca se transmite la contraseña en texto plano en la red.
3. **Petición al Cloud Relay:** El frontend envía las credenciales hasheadas a la ruta `POST /api/auth/login` del microservicio FastAPI en la nube.
4. **Validación Segura:** La API compara el usuario y el hash con las variables de entorno `ADMIN_USER` y `ADMIN_PASSWORD_HASH` mediante comparación en tiempo constante (`hmac.compare_digest`) para prevenir ataques de temporización.
5. **Emisión de Token JWT:** Si la validación es correcta, la API emite un token JWT firmado con algoritmo HS256 y un tiempo de expiración (ej. 24 horas).
6. **Almacenamiento en `sessionStorage`:** El frontend guarda el token únicamente en la memoria de la pestaña del navegador (`sessionStorage`), reduciendo el riesgo de persistencia indebida.
7. **Guardia de Navegación (`AuthGuard`):** Las rutas protegidas validan la presencia y vigencia del token antes de renderizar los gráficos de telemetría.
