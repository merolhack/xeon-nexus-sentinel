# Script para preparar los archivos de arranque PXE de AlmaLinux 9 con timeouts estrictos
$ErrorActionPreference = "Stop"

$pxeDir = "C:\Users\lenin\pxeboot\almalinux9"
if (-not (Test-Path $pxeDir)) {
    New-Item -ItemType Directory -Path $pxeDir -Force | Out-Null
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Preparacion de Archivos PXE Boot para AlmaLinux 9      " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Directorio destino: $pxeDir"

$baseUrl = "https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/images/pxeboot"
$files = @(
    @{ Name = "vmlinuz"; Url = "$baseUrl/vmlinuz"; ExpectedMB = 15; MinMB = 10 },
    @{ Name = "initrd.img"; Url = "$baseUrl/initrd.img"; ExpectedMB = 220; MinMB = 100 }
)

foreach ($f in $files) {
    $targetPath = Join-Path $pxeDir $f.Name
    $needsDownload = $true
    if (Test-Path $targetPath) {
        $sizeMB = [math]::Round(((Get-Item $targetPath).Length / 1MB), 2)
        if ($sizeMB -ge $f.MinMB) {
            Write-Host "-> $($f.Name) ya existe localmente y es valido ($sizeMB MB). Saltando descarga." -ForegroundColor Green
            $needsDownload = $false
        } else {
            Write-Host "-> $($f.Name) existente mide solo $sizeMB MB (posible error 404). Eliminando..." -ForegroundColor Yellow
            Remove-Item $targetPath -Force
        }
    }
    
    if ($needsDownload) {
        Write-Host "Descargando $($f.Name) (~$($f.ExpectedMB) MB)..." -ForegroundColor Yellow
        # Descarga con curl con timeouts estrictos obligatorios (Mandato 6)
        $curlArgs = @(
            "-L",
            "--connect-timeout", "10",
            "--max-time", "600",
            "--progress-bar",
            "-o", $targetPath,
            $f.Url
        )
        & curl.exe @curlArgs

        if (Test-Path $targetPath) {
            $downloadedMB = [math]::Round(((Get-Item $targetPath).Length / 1MB), 2)
            if ($downloadedMB -ge $f.MinMB) {
                Write-Host "Descargado $($f.Name) con exito: $downloadedMB MB" -ForegroundColor Green
            } else {
                Write-Error "Fallo la descarga de $($f.Name) o tamano invalido ($downloadedMB MB)."
                exit 1
            }
        } else {
            Write-Error "Fallo la descarga de $($f.Name)."
            exit 1
        }
    }
}

Write-Host "----------------------------------------------------------"
Write-Host "Archivos de arranque listos en $pxeDir" -ForegroundColor Green
Get-ChildItem $pxeDir | Format-Table Name, Length, LastWriteTime -AutoSize
