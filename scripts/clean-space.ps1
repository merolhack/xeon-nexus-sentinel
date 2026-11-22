# Script de limpieza en espacio de usuario (Sin privilegios de administrador)
Write-Host "==> Verificando almacenamiento libre antes de la limpieza..." -ForegroundColor Cyan
$volBefore = Get-Volume -DriveLetter C
$freeBefore = [math]::Round($volBefore.SizeRemaining / 1GB, 2)
Write-Host "Espacio libre inicial en C: $freeBefore GB"

# 1. Limpieza de carpeta temporal del usuario (%TEMP%)
$userTemp = $env:TEMP
Write-Host "==> Limpiando carpeta temporal de usuario ($userTemp)..."
if (Test-Path $userTemp) {
    Get-ChildItem -Path $userTemp -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { -not $_.PSIsContainer } | ForEach-Object {
        try {
            Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue
        } catch {}
    }
    # Eliminar carpetas vacias
    Get-ChildItem -Path $userTemp -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer } | ForEach-Object {
        try {
            Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        } catch {}
    }
}

# 2. Limpieza de CrashDumps de usuario
$crashDumps = Join-Path $env:LOCALAPPDATA "CrashDumps"
if (Test-Path $crashDumps) {
    Write-Host "==> Limpiando CrashDumps en $crashDumps..."
    Remove-Item -Path "$crashDumps\*" -Force -Recurse -ErrorAction SilentlyContinue
}

# 3. Limpieza de caché de npm
Write-Host "==> Purgando caché de npm..."
cmd.exe /c "npm cache clean --force" 2>$null

# 4. Limpieza de caché de pip
Write-Host "==> Purgando caché de pip..."
cmd.exe /c "python -m pip cache purge" 2>$null

# 5. Espacio resultante
$volAfter = Get-Volume -DriveLetter C
$freeAfter = [math]::Round($volAfter.SizeRemaining / 1GB, 2)
$recovered = [math]::Round($freeAfter - $freeBefore, 2)
Write-Host "==========================================" -ForegroundColor Green
Write-Host "Espacio libre final en C: $freeAfter GB" -ForegroundColor Green
Write-Host "Espacio recuperado: $recovered GB" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
