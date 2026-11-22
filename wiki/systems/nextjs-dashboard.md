---
type: system
title: "Frontend Next.js en GitHub Pages"
description: "Panel de control estático con autenticación en cliente para monitoreo de telemetría y estado de servidores"
tags: [nextjs, react, tailwindcss, typescript, github-pages, ssg]
created: 2026-11-22
updated: 2026-11-22
---

# Frontend Next.js en GitHub Pages (`dashboard`)

## 1. Arquitectura de Exportación Estática

La aplicación está construida sobre **Next.js 14+** con App Router y configurada con `output: 'export'`. Esto permite que el sitio se compile a un conjunto de ficheros HTML, JS y CSS listos para ser servidos por la infraestructura CDN de GitHub Pages sin costo.

## 2. Componentes Clave

1. **`AuthGuard.tsx`**: Componente de orden superior que intercepta la navegación. Comprueba la validez del token JWT almacenado en `sessionStorage`; si expira o no existe, redirige de inmediato a `/login`.
2. **`ServerMetrics.tsx`**: Representación gráfica y métricas en tiempo real de porcentaje de CPU por hilo, memoria RAM ocupada, swap, temperatura y latencia de red.
3. **`AiStatus.tsx`**: Monitor del motor de inferencia local. Indica el modelo activo, velocidad de procesamiento en tokens por segundo (tok/s) y latencia al primer token (TTFT).
4. **`MiningStatus.tsx`**: Panel de telemetría de XMRig con hashrate instantáneo (H/s), hilos asignados, shares validados y estado del semáforo de gobernanza de recursos.
5. **`lib/crypto.ts`**: Utilidad criptográfica cliente que calcula el resumen SHA-256 o PBKDF2 de la contraseña antes de su transmisión a la API.

## 3. Parámetros de Configuración (`next.config.mjs`)
- `basePath`: `'/xeon-nexus-sentinel'`
- `trailingSlash`: `true`
- `images`: `{ unoptimized: true }`
