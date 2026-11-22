---
title: "Optimización de Almacenamiento Local y Respaldo en Google Drive con Rclone"
type: "concept"
category: "storage"
tags: ["storage", "rclone", "gdrive", "backup", "windows11", "wsl", "disk-cleanup"]
last_updated: "2026-11-22"
status: "active"
---

# Optimización de Almacenamiento Local y Respaldo en Google Drive con Rclone

## 1. Visión General

El entorno de desarrollo y operación de **Xeon Nexus Sentinel** requiere balancear el espacio en disco de la estación de control (Laptop Windows 11 con WSL2) con las necesidades de compilación, modelos locales de IA y telemetría.

Para evitar saturación de la partición de sistema `C:`, se implementó una estrategia híbrida de dos niveles:
1. **Limpieza interna periódica sin privilegios de administrador:** Eliminación de cachés de npm, pip, NuGet, temporales de usuario y artefactos de desarrollo (`node_modules` inactivos, `.next/cache`).
2. **Respaldo y liberación de espacio en nube con `rclone`:** Conexión directa a Google Drive (cuenta de 5 TiB con 4.899 TiB disponibles) mediante binario portable en espacio de usuario (`C:\Users\lenin\rclone\rclone.exe`) y script de orquestación `scripts/gdrive-backup.ps1`.

---

## 2. Métricas de Capacidad Verificadas

- **Capacidad Total en Google Drive:** 5 TiB
- **Espacio Libre en Nube:** 4.899 TiB
- **Espacio Utilizado Actual:** 19.038 GiB
- **Espacio Recuperado en Windows C:** +19.91 GB (de 8.94 GB a 28.85 GB libres)
- **Espacio Reclamado en WSL2:** +33 GB (de 85 GB a 52 GB usados)

---

## 3. Automatización: `scripts/gdrive-backup.ps1`

El script implementa tres operaciones principales con validación de integridad previa al borrado:

| Acción | Modo Rclone | Comportamiento | Casos de Uso Recomendados |
| :--- | :--- | :--- | :--- |
| `Copy` | `rclone copy` | Duplica los archivos locales en la nube sin alterar el origen. | Respaldos preventivos de código, configuraciones y modelos. |
| `Move` | `rclone move` | Transfiere a la nube y **elimina localmente sólo tras verificación SHA-1**. | Liberación de espacio en carpetas de Descargas, renders o videos. |
| `Sync` | `rclone sync` | Mantiene el destino exactamente idéntico al origen. | Espejado unidireccional de directorios de trabajo. |

### Parámetros Principales
- `-SourcePath`: Ruta local de origen (ej: `C:\Users\lenin\Downloads`).
- `-RemotePath`: Directorio remoto en Google Drive (por defecto: `gdrive:Laptop_Thunderobot/Backups`).
- `-MinAgeDays`: Filtra únicamente archivos con más de N días de antigüedad (ej: `-MinAgeDays 60` para mover sólo descargas antiguas).
- `-DryRun`: Switch de simulación que lista las acciones sin realizar ningún cambio ni borrado.

---

## 4. Ejemplos de Uso en PowerShell

### Simulación preventiva (Dry-Run)
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\gdrive-backup.ps1 -SourcePath "C:\Users\lenin\Downloads" -MinAgeDays 60 -Action Move -DryRun
```

### Liberación real de espacio para archivos con más de 60 días
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\gdrive-backup.ps1 -SourcePath "C:\Users\lenin\Downloads" -MinAgeDays 60 -Action Move
```

### Respaldo de proyectos o documentos sin borrar localmente
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\gdrive-backup.ps1 -SourcePath "C:\Users\lenin\Documents" -Action Copy
```
