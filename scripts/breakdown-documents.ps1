$docPath = 'C:\Users\lenin\Documents'
$dateCutOff = Get-Date '2026-01-01'

Write-Host "=========================================================="
Write-Host " Desglose de C:\Users\lenin\Documents (Anteriores a 2026) "
Write-Host "=========================================================="

Get-ChildItem -Path $docPath -Directory | ForEach-Object {
    $dir = $_
    $oldFiles = Get-ChildItem -Path $dir.FullName -Recurse -File -ErrorAction SilentlyContinue | Where-Object {
        $_.LastWriteTime -lt $dateCutOff
    }
    $count = ($oldFiles | Measure-Object).Count
    if ($count -gt 0) {
        $sumBytes = ($oldFiles | Measure-Object -Property Length -Sum).Sum
        $sizeMB = [math]::Round(($sumBytes / 1MB), 2)
        $sizeGB = [math]::Round(($sumBytes / 1GB), 2)
        Write-Host "$($dir.Name) -> $count archivos antiguos | $sizeMB MB ($sizeGB GB)"
    }
}

# Archivos sueltos en la raíz de Documents
$rootOldFiles = Get-ChildItem -Path $docPath -File -ErrorAction SilentlyContinue | Where-Object {
    $_.LastWriteTime -lt $dateCutOff
}
$rootCount = ($rootOldFiles | Measure-Object).Count
if ($rootCount -gt 0) {
    $rootBytes = ($rootOldFiles | Measure-Object -Property Length -Sum).Sum
    $rootMB = [math]::Round(($rootBytes / 1MB), 2)
    Write-Host "Archivos en raiz de Documents -> $rootCount archivos | $rootMB MB"
}
Write-Host "=========================================================="
