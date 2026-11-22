<#
.SYNOPSIS
    Script automatizado de respaldo y liberacion de espacio en Google Drive mediante rclone.
.DESCRIPTION
    Permite respaldar o mover archivos locales hacia la nube de Google Drive usando 'gdrive:'.
    Incorpora soporte para filtro de inactividad estricta comprobando tanto fecha de modificacion
    (LastWriteTime) como fecha de ultimo acceso real (LastAccessTime).
.PARAMETER SourcePath
    Ruta local del directorio a respaldar (ej: C:\Users\lenin\Documents).
.PARAMETER RemotePath
    Ruta de destino en Google Drive (ej: gdrive:Backup/Documents).
.PARAMETER MinAgeDays
    Filtrar archivos modificados hace mas de N dias.
.PARAMETER BeforeDate
    Filtrar archivos anteriores a una fecha especifica (ej: '2026-01-01').
.PARAMETER CheckLastAccess
    Si se activa, exige que el archivo TAMPOCO haya sido abierto ni leido despues de la fecha de corte.
    Evita borrar archivos antiguos que sigues utilizando en el dia a dia.
.PARAMETER Action
    'Copy' (copia manteniendo original), 'Move' (transfiere y libera espacio tras verificar SHA1) o 'Sync'.
.PARAMETER DryRun
    Simula la transferencia sin mover ni modificar ningun archivo.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$SourcePath = "C:\Users\lenin\Documents",

    [Parameter(Mandatory = $false)]
    [string]$RemotePath = "gdrive:Backup/Documents",

    [Parameter(Mandatory = $false)]
    [int]$MinAgeDays = 0,

    [Parameter(Mandatory = $false)]
    [string]$BeforeDate = "2026-01-01",

    [Parameter(Mandatory = $false)]
    [switch]$CheckLastAccess = $true,

    [Parameter(Mandatory = $false)]
    [ValidateSet("Copy", "Move", "Sync")]
    [string]$Action = "Copy",

    [Parameter(Mandatory = $false)]
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Stop"

$rcloneBin = "C:\Users\lenin\rclone\rclone.exe"
if (-not (Test-Path $rcloneBin)) {
    $rcloneCmd = Get-Command rclone -ErrorAction SilentlyContinue
    if ($rcloneCmd) {
        $rcloneBin = $rcloneCmd.Source
    } else {
        Write-Error "rclone no se encontro en C:\Users\lenin\rclone\rclone.exe ni en el PATH."
        exit 1
    }
}

if (-not (Test-Path $SourcePath)) {
    Write-Error "El directorio de origen no existe: $SourcePath"
    exit 1
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Xeon Nexus Sentinel - Google Drive Backup & Archive    " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Origen local          : $SourcePath"
Write-Host "Destino remoto        : $RemotePath"
Write-Host "Accion                : $Action"
Write-Host "Filtro de fecha       : Anterior a $BeforeDate"
Write-Host "Verificar Ult. Acceso : $(if ($CheckLastAccess) { 'SI (Protege archivos abiertos/usados recientemente)' } else { 'NO' })"
Write-Host "Modo simulacion       : $(if ($DryRun) { 'SI (Dry-Run)' } else { 'NO (Transferencia real)' })"
Write-Host "----------------------------------------------------------"

$cutOffDate = Get-Date $BeforeDate

if ($CheckLastAccess) {
    Write-Host "Analizando arbol de archivos con verificacion dual (Escritura y Acceso)..." -ForegroundColor Yellow
    $allFiles = Get-ChildItem -Path $SourcePath -Recurse -File -ErrorAction SilentlyContinue
    
    $inactiveFiles = $allFiles | Where-Object {
        $_.LastWriteTime -lt $cutOffDate -and $_.LastAccessTime -lt $cutOffDate
    }

    $count = ($inactiveFiles | Measure-Object).Count
    $totalBytes = ($inactiveFiles | Measure-Object -Property Length -Sum).Sum
    if (-not $totalBytes) { $totalBytes = 0 }
    $totalMB = [math]::Round(($totalBytes / 1MB), 2)
    $totalGB = [math]::Round(($totalBytes / 1GB), 2)

    Write-Host "Archivos verdaderamente inactivos detectados: $count ($totalMB MB / $totalGB GB)" -ForegroundColor Green
    
    if ($count -eq 0) {
        Write-Host "No se encontraron archivos inactivos que cumplan ambas condiciones. Nada que transferir." -ForegroundColor Cyan
        exit 0
    }

    # Generar lista relativa para rclone --files-from-slash
    $listFile = [System.IO.Path]::GetTempFileName()
    $relativePaths = $inactiveFiles | ForEach-Object {
        $_.FullName.Substring($SourcePath.TrimEnd('\').Length + 1).Replace('\', '/')
    }
    $relativePaths | Set-Content -Path $listFile -Encoding UTF8

    $cmdArgs = @()
    switch ($Action) {
        "Copy" { $cmdArgs += "copy" }
        "Move" { $cmdArgs += "move" }
        "Sync" { $cmdArgs += "sync" }
    }
    $cmdArgs += $SourcePath
    $cmdArgs += $RemotePath
    $cmdArgs += "--files-from-slash"
    $cmdArgs += $listFile
    $cmdArgs += "--progress"
    $cmdArgs += "--transfers=4"
    $cmdArgs += "--checkers=8"

    if ($DryRun) {
        $cmdArgs += "--dry-run"
    }

    Write-Host "Ejecutando rclone con lista filtrada..." -ForegroundColor Yellow
    & $rcloneBin @cmdArgs

    Remove-Item $listFile -Force -ErrorAction SilentlyContinue
} else {
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
    $cmdArgs += "--min-age"
    $cmdArgs += $BeforeDate

    if ($DryRun) {
        $cmdArgs += "--dry-run"
    }

    & $rcloneBin @cmdArgs
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "Operacion finalizada exitosamente." -ForegroundColor Green
} else {
    Write-Host "rclone finalizo con codigo: $LASTEXITCODE" -ForegroundColor Red
}
