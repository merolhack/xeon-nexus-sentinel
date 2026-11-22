<#
.SYNOPSIS
    Script automatizado de respaldo y liberación de espacio en Google Drive mediante rclone.
.DESCRIPTION
    Permite respaldar o mover archivos locales (por ejemplo Descargas, grabaciones o archivos antiguos)
    hacia la nube de Google Drive usando el remoto autenticado 'gdrive:'.
    Cumple con la política de cero elevación de privilegios (opera como usuario estándar).
.PARAMETER SourcePath
    Ruta local del directorio a respaldar (ej: C:\Users\lenin\Downloads).
.PARAMETER RemotePath
    Ruta de destino en Google Drive (ej: gdrive:Laptop_Thunderobot/Backups).
.PARAMETER MinAgeDays
    Filtrar sólo archivos modificados hace más de N días (útil para archivar sin tocar archivos recientes).
.PARAMETER Action
    'Copy' (copia manteniendo original) o 'Move' (transfiere y libera espacio en disco local tras verificar).
.PARAMETER DryRun
    Simula la transferencia sin mover ni modificar ningún archivo.
.EXAMPLE
    .\scripts\gdrive-backup.ps1 -SourcePath "C:\Users\lenin\Downloads" -Action Copy -DryRun
.EXAMPLE
    .\scripts\gdrive-backup.ps1 -SourcePath "C:\Users\lenin\Downloads" -MinAgeDays 60 -Action Move
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$SourcePath = "C:\Users\lenin\Downloads",

    [Parameter(Mandatory = $false)]
    [string]$RemotePath = "gdrive:Laptop_Thunderobot/Backups",

    [Parameter(Mandatory = $false)]
    [int]$MinAgeDays = 0,

    [Parameter(Mandatory = $false)]
    [ValidateSet("Copy", "Move", "Sync")]
    [string]$Action = "Copy",

    [Parameter(Mandatory = $false)]
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Stop"

$rcloneBin = "C:\Users\lenin\rclone\rclone.exe"
if (-not (Test-Path $rcloneBin)) {
    # Probar si está en el PATH
    $rcloneCmd = Get-Command rclone -ErrorAction SilentlyContinue
    if ($rcloneCmd) {
        $rcloneBin = $rcloneCmd.Source
    } else {
        Write-Error "rclone no se encontró en C:\Users\lenin\rclone\rclone.exe ni en el PATH del sistema."
        exit 1
    }
}

if (-not (Test-Path $SourcePath)) {
    Write-Error "El directorio de origen especificado no existe: $SourcePath"
    exit 1
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Xeon Nexus Sentinel - Google Drive Backup & Archive    " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Origen local     : $SourcePath"
Write-Host "Destino remoto   : $RemotePath"
Write-Host "Accion           : $Action"
Write-Host "Filtro antiguedad: $(if ($MinAgeDays -gt 0) { "$MinAgeDays dias" } else { "Todos los archivos" })"
Write-Host "Modo simulacion  : $(if ($DryRun) { 'SI (Dry-Run)' } else { 'NO (Transferencia real)' })"
Write-Host "Binario rclone   : $rcloneBin"
Write-Host "----------------------------------------------------------"

$cmdArgs = @()

switch ($Action) {
    "Copy" { $cmdArgs += "copy" }
    "Move" { $cmdArgs += "move" }
    "Sync" { $cmdArgs += "sync" }
}

$cmdArgs += $SourcePath
$cmdArgs += $RemotePath
$cmdArgs += "--progress"
$cmdArgs += "--transfers=4"
$cmdArgs += "--checkers=8"
$cmdArgs += "--drive-chunk-size=64M"

if ($MinAgeDays -gt 0) {
    $cmdArgs += "--min-age"
    $cmdArgs += "${MinAgeDays}d"
}

if ($DryRun) {
    $cmdArgs += "--dry-run"
}

Write-Host "Ejecutando: $rcloneBin $($cmdArgs -join ' ')" -ForegroundColor Yellow
Write-Host ""

& $rcloneBin @cmdArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Operacion completada con exito." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "rclone finalizo con codigo de salida: $LASTEXITCODE" -ForegroundColor Red
}
