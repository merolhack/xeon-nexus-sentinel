# Script para instalar rclone portable en espacio de usuario (Sin Admin)
$rcloneDir = "C:\Users\lenin\rclone"
if (-not (Test-Path $rcloneDir)) {
    New-Item -ItemType Directory -Path $rcloneDir -Force | Out-Null
}

$zipPath = Join-Path $rcloneDir "rclone.zip"
Write-Host "==> Descargando rclone standalone oficial (64-bit)..." -ForegroundColor Cyan
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri "https://downloads.rclone.org/rclone-current-windows-amd64.zip" -OutFile $zipPath

Write-Host "==> Descomprimiendo rclone..." -ForegroundColor Cyan
Expand-Archive -Path $zipPath -DestinationPath $rcloneDir -Force

$foundExe = Get-ChildItem -Path $rcloneDir -Filter "rclone.exe" -Recurse | Select-Object -First 1
if ($foundExe) {
    Copy-Item -Path $foundExe.FullName -Destination (Join-Path $rcloneDir "rclone.exe") -Force
    Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue
    Write-Host "=================================================" -ForegroundColor Green
    Write-Host "✅ rclone instalado exitosamente en: $rcloneDir\rclone.exe" -ForegroundColor Green
    & "$rcloneDir\rclone.exe" version
    Write-Host "=================================================" -ForegroundColor Green
} else {
    Write-Host "❌ Error: No se encontro rclone.exe en el zip" -ForegroundColor Red
}

# Agregar C:\Users\lenin\rclone a la variable PATH de usuario (sin requerir admin)
$userPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
if ($userPath -notlike "*$rcloneDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$rcloneDir", [EnvironmentVariableTarget]::User)
    Write-Host "✅ C:\Users\lenin\rclone agregado al PATH del usuario permanentemente." -ForegroundColor Green
}
