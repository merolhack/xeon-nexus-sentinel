# Script para grabar ipxe.iso en CD-R de forma desatendida
$ErrorActionPreference = "Stop"

$isoPath = "C:\Users\lenin\pxeboot\ipxe.iso"
$driveLetter = "E:"

if (-not (Test-Path $isoPath)) {
    Write-Error "No se encontro la imagen $isoPath"
    exit 1
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Grabacion Desatendida de iPXE en CD-R (Unidad $driveLetter)  " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Archivo ISO: $isoPath ($([math]::Round(((Get-Item $isoPath).Length / 1MB), 2)) MB)"
Write-Host "Grabadora:   PHILIPS CDRW/DVD ($driveLetter)"
Write-Host "Iniciando Windows Disc Image Burner en modo desatendido..." -ForegroundColor Yellow

$proc = Start-Process -FilePath "C:\Windows\System32\isoburn.exe" -ArgumentList "/Q", "$driveLetter", "$isoPath" -PassThru

Write-Host "Proceso isoburn.exe activo con PID: $($proc.Id)" -ForegroundColor Cyan
Write-Host "Monitoreando estado de la grabacion..."

$timeout = 180
$elapsed = 0

while (-not $proc.HasExited -and $elapsed -lt $timeout) {
    Start-Sleep -Seconds 3
    $elapsed += 3
    if ($elapsed % 9 -eq 0) {
        Write-Host "   -> Grabando pistas en CD-R... ($elapsed s transcurridos)" -ForegroundColor Gray
    }
}

if ($proc.HasExited) {
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "   Grabacion finalizada con codigo: $($proc.ExitCode)     " -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
} else {
    Write-Host "La grabacion sigue en curso tras $elapsed segundos..." -ForegroundColor Yellow
}
