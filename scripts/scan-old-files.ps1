$dateCutOff = Get-Date '2026-01-01'
$targetFolders = @(
    'C:\Users\lenin\Downloads',
    'C:\Users\lenin\Documents',
    'C:\Users\lenin\Desktop',
    'C:\Users\lenin\Videos',
    'C:\Users\lenin\Pictures',
    'C:\Users\lenin\Music'
)

Write-Host "=========================================================="
Write-Host " Escaneo de Archivos Antiguos (Antes de 2026-01-01) "
Write-Host "=========================================================="

$grandTotalBytes = 0
$grandTotalCount = 0

foreach ($folder in $targetFolders) {
    if (Test-Path $folder) {
        $files = Get-ChildItem -Path $folder -Recurse -File -ErrorAction SilentlyContinue | Where-Object {
            $_.LastWriteTime -lt $dateCutOff
        }
        $count = ($files | Measure-Object).Count
        $sumBytes = ($files | Measure-Object -Property Length -Sum).Sum
        if (-not $sumBytes) { $sumBytes = 0 }
        $sizeMB = [math]::Round(($sumBytes / 1MB), 2)
        $sizeGB = [math]::Round(($sumBytes / 1GB), 2)
        
        $grandTotalBytes += $sumBytes
        $grandTotalCount += $count

        Write-Host "Carpeta: $folder"
        Write-Host "  -> Archivos: $count"
        Write-Host "  -> Tamano  : $sizeMB MB ($sizeGB GB)"
    }
}

Write-Host "----------------------------------------------------------"
$grandGB = [math]::Round(($grandTotalBytes / 1GB), 2)
Write-Host "TOTAL GENERAL: $grandTotalCount archivos | $grandGB GB"
Write-Host "=========================================================="
