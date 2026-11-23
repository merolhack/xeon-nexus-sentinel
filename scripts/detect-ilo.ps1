# Script para detectar y verificar la IP de HP iLO 100i en el puerto de gestion superior
$ErrorActionPreference = "SilentlyContinue"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Deteccion de HP iLO 100i (Dedicated Mgmt Port)         " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Verificar velocidad de enlace
$adapter = Get-NetAdapter -Name "Ethernet"
Write-Host "Estado actual del adaptador: $($adapter.Status) @ $($adapter.LinkSpeed)"

# 2. Barrido rapido de ARP en subred 192.168.137.x con timeout estricto
Write-Host "Buscando dispositivos activos en 192.168.137.x..." -ForegroundColor Yellow

$activeIPs = @()
1..20 | ForEach-Object {
    $ip = "192.168.137.$_"
    $ping = Test-Connection -ComputerName $ip -Count 1 -TimeoutSeconds 1 -Quiet
    if ($ping -and $ip -ne "192.168.137.1") {
        $activeIPs += $ip
        Write-Host "   [+] IP Respondiendo a Ping: $ip" -ForegroundColor Green
    }
}

# 3. Consultar tabla ARP
$arpEntries = Get-NetNeighbor -InterfaceAlias "Ethernet" | Where-Object {
    $_.State -ne "Unreachable" -and 
    $_.State -ne "Permanent" -and 
    $_.IPAddress -like "192.168.137.*"
}

if ($arpEntries) {
    foreach ($entry in $arpEntries) {
        Write-Host "   [+] Dispositivo ARP detectado: $($entry.IPAddress) [MAC: $($entry.LinkLayerAddress)]" -ForegroundColor Green
        if ($entry.IPAddress -notin $activeIPs -and $entry.IPAddress -ne "192.168.137.1") {
            $activeIPs += $entry.IPAddress
        }
    }
}

# 4. Probar puertos iLO (80, 443, 22, 23)
foreach ($ip in $activeIPs) {
    Write-Host "Probando puertos de gestion en $ip..." -ForegroundColor Cyan
    foreach ($p in @(80, 443, 22, 23)) {
        $t = Test-NetConnection -ComputerName $ip -Port $p -WarningAction SilentlyContinue
        if ($t.TcpTestSucceeded) {
            Write-Host "   -> Puerto $p ABIERTO en $ip (HP iLO 100i activo)" -ForegroundColor Green
        }
    }
}

if ($activeIPs.Count -eq 0) {
    Write-Host "Aun no se detectan IPs activas en 192.168.137.x." -ForegroundColor Yellow
}
