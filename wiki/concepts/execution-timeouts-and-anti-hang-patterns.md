---
title: "Patrones Anti-Bloqueo y Políticas Estrictas de Timeout en Comandos del Agente"
type: "concept"
category: "resilience"
tags: ["timeout", "anti-hang", "networking", "agent-behavior", "best-practices", "devops"]
last_updated: "2026-11-22"
status: "active"
---

# Patrones Anti-Bloqueo y Políticas Estrictas de Timeout en Comandos del Agente

## 1. Análisis de Causa Raíz (Post-Mortem: Bloqueo de 39 Minutos)

Durante la preparación del entorno PXE a las 19:24 UTC, el agente emitió un comando de verificación HTTP contra el repositorio de arranque de AlmaLinux 9:
```bash
curl -I https://repo.almalinux.org/almalinux/9/os/x86_64/os/images/pxeboot/
```

### Factores Determinantes del Bloqueo:
1. **Ausencia de Parámetros de Timeout:** `curl` por defecto en Windows PowerShell no impone un límite de tiempo estricto para resolución de DNS o establecimiento de socket (`--connect-timeout` ni `--max-time`). Ante una latencia en el handshake o filtrado en el endpoint, el proceso quedó colgado indefinidamente.
2. **Delegación a Segundo Plano de Tarea Ligera:** El comando fue enviado con `WaitMsBeforeAsync: 5000` y al superar los 5 segundos pasó a tarea de segundo plano (`task-914`).
3. **Espera Reactiva Pasiva sin Guardia:** El agente finalizó el turno esperando el mensaje de notificación del sistema. Al no terminar el proceso hijo, el hilo de interacción quedó congelado por 39 minutos hasta la intervención manual del usuario.

---

## 2. Directivas Técnicas Obligatorias (Regla Anti-Hang)

Para garantizar que este comportamiento jamás se repita, se establecen las siguientes directivas de ingeniería:

### Regla 1: Timeouts Mandatorios y Acotados
Todo comando de red, consulta HTTP, sondeo de sockets o escaneo de puertos DEBE llevar parámetros de límite de tiempo explícitos:
- **En `curl`:** Siempre incluir `--connect-timeout 5 --max-time 10`.
- **En PowerShell `Invoke-WebRequest`:** Siempre pasar `-TimeoutSec 5`.
- **En sockets .NET / Python:** Configurar `ReceiveTimeout = 3000` y `socket.settimeout(3.0)`.

```powershell
# FORMA CORRECTA
curl -I --connect-timeout 5 --max-time 10 https://repo.almalinux.org/...
Invoke-WebRequest -Uri "https://..." -TimeoutSec 5 -UseBasicParsing
```

### Regla 2: Prohibición de Segundo Plano en Tareas de Diagnóstico
Los comandos de prueba de conectividad, verificación de URLs, comprobaciones de estado y sondeos de adaptadores son operaciones que **deben resolverse sincrónicamente en menos de 5 a 8 segundos**.
- Si un comando de diagnóstico no responde en 5 segundos, debe ser cancelado inmediatamente y el agente debe reportar el resultado (endpoint inalcanzable o timeout) sin ceder el control a una espera pasiva.

### Regla 3: Tareas de Fondo Exclusivas para Cargas Pesadas
Solo las transferencias de datos masivas (como respaldos de gigabytes con `rclone` o compilaciones de software extensas) tienen permitido ejecutarse en segundo plano, e incluso estas deben incluir telemetría periódica (`--stats 10s`) y un informe inmediato al usuario sin bloquear la conversación.
