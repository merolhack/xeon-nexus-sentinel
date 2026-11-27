---
type: entity
title: "Nodo de Trabajo: Laptop THUNDEROBOT ZERO (Windows 11 Pro)"
description: "Estación de trabajo y control con Intel Core i9-13900HX, 32 GB DDR5, NVIDIA RTX 4060 8GB y enlace Gigabit directo al servidor HP"
tags: [laptop, thunderobot-zero, rtx-4060, i9-13900hx, windows11, cuda, hybrid-ai]
created: 2026-11-26
updated: 2026-11-26
---

# Nodo de Trabajo: Laptop THUNDEROBOT ZERO (`laptop-node`)

## 1. Identificación y Rol Arquitectónico
* **Identificador de Nodo:** `laptop-node` / `THUNDEROBOT-ZERO`.
* **Sistema Operativo:** Microsoft Windows 11 Pro (64-bit, Build 26200).
* **Rol en el Ecosistema:** Estación principal de desarrollo, interfaz gráfica de usuario (Next.js Dashboard, Cockpit), orquestación de agentes IA (Antigravity IDE) y aceleración por GPU (CUDA / Tensor Cores) para inferencia rápida y generación de embeddings.
* **Topología de Red:** Puerta de enlace (`192.168.137.1`) que provee conexión a Internet compartida (ICS) y enlace Gigabit directo por cable Ethernet hacia el servidor HP ProLiant ML150 G6 (`192.168.137.50`).

---

## 2. Especificaciones de Hardware Auditadas en Vivo (PowerShell / CIM)

### A. Procesador (CPU)
* **Modelo:** 13th Gen Intel Core i9-13900HX (Raptor Lake).
* **Topología de Núcleos:** 24 núcleos físicos / 32 procesadores lógicos:
  * 8 Performance-cores (P-cores) con Hyper-Threading (hasta 5.40 GHz Turbo).
  * 16 Efficient-cores (E-cores) para tareas en segundo plano.
* **Caché L3:** 36 MB Intel Smart Cache.
* **Conjunto de Instrucciones:** AVX, AVX2, FMA3, BMI2, SSE4.2, Intel DL Boost (VNNI) para aceleración de inferencia en CPU.

### B. Memoria RAM
* **Capacidad Total:** 32 GB (34,359,738,368 bytes / 33.28 GB visibles).
* **Configuración:** 2 ranuras SODIMM pobladas en Dual-Channel:
  * Ranura 1: 16 GB Samsung DDR5-5600 MT/s (`M425R2GA3BB0-CWMOD`).
  * Ranura 2: 16 GB Samsung DDR5-5600 MT/s (`M425R2GA3BB0-CWMOD`).
* **Memoria Libre en Auditoría:** ~7.28 GB libres físicos en reposo de desarrollo.

### C. Subsistema Gráfico (GPU Dual)
1. **GPU Integrada (Bajo Consumo):**
   * Intel UHD Graphics (Raptor Lake-S Mobile Graphics Controller).
   * 1 GB RAM asignada, encargada de la pantalla principal y reproducción multimedia ligera.
2. **GPU Dedicada (Aceleración IA / CUDA):**
   * **Modelo:** NVIDIA GeForce RTX 4060 Laptop GPU.
   * **Arquitectura:** Ada Lovelace (4 nm TSMC).
   * **VRAM Dedicada:** 8 GB GDDR6 (8,188 MiB total, ~7,956 MiB libres para modelos).
   * **Capacidad de Cómputo (Compute Capability):** **8.9** (Tensor Cores de 4ª generación, núcleos RT de 3ª generación, soporte nativo FP8, FP16, INT8, INT4).
   * **Controlador NVIDIA:** Versión 562.24 (Driver 32.0.16.2124), compatible con CUDA 12.x.
   * **Temperatura en Reposo:** ~45.8 °C con consumo base de 15.0W.

### D. Almacenamiento
* **Unidad Física:** SSD NVMe M.2 de 1 TB (`KPEGYMTBW2U001TCJD`), Bus PCIe NVMe, estado Healthy.
* **Partición C: (NTFS):** 1,022 GB de capacidad total, ~23.2 GB libres (requiere políticas de retención con `rclone` hacia Google Drive de 5 TiB).

### E. Conectividad y Redes
* **Ethernet Primario (Enlace Servidor):** Realtek PCIe GbE Family Controller (`74:D4:DD:44:D8:80`) operando a **1 Gbps Full Duplex** hacia el servidor HP (`192.168.137.1` -> `192.168.137.50`).
* **Wi-Fi WAN:** Intel Wi-Fi 6 AX201 160MHz (`F0:20:FF:14:BC:16`).
* **Virtualización:** Hyper-V activado (`HypervisorPresent: True`), WSL2 operativo con Ubuntu 20.04.

---

## 3. Scripts Estándar de PowerShell para Auditoría en Windows 11

Para reproducir esta telemetría en cualquier momento sin herramientas de terceros:

```powershell
# 1. CPU y Núcleos
Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed, L3CacheSize | Format-List

# 2. GPU NVIDIA (CUDA / VRAM / Drivers)
nvidia-smi --query-gpu=name,memory.total,memory.free,driver_version,compute_cap,power.draw,temperature.gpu --format=csv,noheader,nounits

# 3. Módulos de Memoria Física
Get-CimInstance Win32_PhysicalMemory | Select-Object DeviceLocator, Capacity, Speed, Manufacturer, PartNumber | Format-Table -AutoSize

# 4. Salud de Discos y Espacio Libre
Get-PhysicalDisk | Select-Object DeviceId, FriendlyName, MediaType, Size, BusType, HealthStatus | Format-Table -AutoSize
Get-CimInstance Win32_LogicalDisk | Select-Object DeviceID, FileSystem, Size, FreeSpace, Description | Format-Table -AutoSize

# 5. Adaptadores de Red y Velocidad de Enlace
Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, LinkSpeed, MacAddress | Format-Table -AutoSize
```
* **Stack de Agente Autónomo Local (Vixl + LiteLLM + Ollama + MCP):** Véase [local-autonomous-agent-stack-vixl-litellm.md](../systems/local-autonomous-agent-stack-vixl-litellm.md) para el detalle de la configuración de Vixl como host MCP, LiteLLM en puerto 4000 con bypass de thinking y Ollama con `qwen3:8b-agent` (16K context).
