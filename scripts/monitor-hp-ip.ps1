Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Monitor de Enlace y Deteccion de Servidor HP (iLO / Xeon) " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan

$ethernet = Get-NetAdapter -Name "Ethernet"
Write-Host "Estado fisico del cable: $($ethernet.Status) ($($ethernet.LinkSpeed))"

$ipObj = Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4 -ErrorAction SilentlyContinue
$currentIP = if ($ipObj) { $ipObj.IPAddress } else { "Sin IP asignada" }
Write-Host "IP actual en Ethernet  : $currentIP"

Write-Host "----------------------------------------------------------"
Write-Host "Buscando dispositivos en la tabla ARP de Ethernet..." -ForegroundColor Yellow

$neighbors = Get-NetNeighbor -InterfaceAlias "Ethernet" -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object {
    $_.IPAddress -notlike "224.*" -and $_.IPAddress -notlike "239.*" -and $_.IPAddress -notlike "255.*" -and $_.IPAddress -notlike "*.255"
}

if ($neighbors) {
    Write-Host "Dispositivos detectados en el cable directo:" -ForegroundColor Green
    $neighbors | Format-Table IPAddress, LinkLayerAddress, State -AutoSize
} else {
    Write-Host "Aun no se registran dispositivos con IP en la tabla ARP." -ForegroundColor Cyan
}

Write-Host "==========================================================" -ForegroundColor Cyan
