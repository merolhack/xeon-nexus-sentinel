$date = Get-Date '2026-01-01'
$docPath = 'C:\Users\lenin\Documents'

Write-Host "=========================================================="
Write-Host " Analisis de Inactividad Real (Escritura vs Acceso) "
Write-Host "=========================================================="

$docFiles = Get-ChildItem $docPath -File -Recurse -ErrorAction SilentlyContinue

$total = ($docFiles | Measure-Object).Count
$oldWritten = $docFiles | Where-Object { $_.LastWriteTime -lt $date }
$oldWrittenCount = ($oldWritten | Measure-Object).Count

$trulyInactive = $docFiles | Where-Object { $_.LastWriteTime -lt $date -and $_.LastAccessTime -lt $date }
$trulyInactiveCount = ($trulyInactive | Measure-Object).Count
$trulyInactiveBytes = ($trulyInactive | Measure-Object -Property Length -Sum).Sum
if (-not $trulyInactiveBytes) { $trulyInactiveBytes = 0 }
$trulyInactiveGB = [math]::Round(($trulyInactiveBytes / 1GB), 2)

$recentlyAccessedOld = $docFiles | Where-Object { $_.LastWriteTime -lt $date -and $_.LastAccessTime -ge $date }
$recentlyAccessedOldCount = ($recentlyAccessedOld | Measure-Object).Count
$recentlyAccessedBytes = ($recentlyAccessedOld | Measure-Object -Property Length -Sum).Sum
if (-not $recentlyAccessedBytes) { $recentlyAccessedBytes = 0 }
$recentlyAccessedGB = [math]::Round(($recentlyAccessedBytes / 1GB), 2)

Write-Host "Total archivos en Documents                     : $total"
Write-Host "Modificados antes de 2026                       : $oldWrittenCount"
Write-Host "Verdaderamente inactivos (No abiertos en 2026)  : $trulyInactiveCount ($trulyInactiveGB GB)"
Write-Host "Antiguos pero ABIERTOS/USADOS en 2026 (Proteger): $recentlyAccessedOldCount ($recentlyAccessedGB GB)"
Write-Host "=========================================================="
