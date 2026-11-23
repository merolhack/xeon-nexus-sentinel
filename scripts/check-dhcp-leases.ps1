Write-Host "--- Verificando leases DHCP en Registro de Windows ---"
$dhcpPath = "HKLM:\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Configurable\System"
if (Test-Path $dhcpPath) {
    Get-ItemProperty $dhcpPath
}

Write-Host "--- Vecinos y ARP en interfaz Ethernet ---"
Get-NetNeighbor -InterfaceAlias "Ethernet" | Format-Table IPAddress, LinkLayerAddress, State -AutoSize

Write-Host "--- Estadisticas actuales de paquetes ---"
Get-NetAdapterStatistics -Name "Ethernet" | Select-Object ReceivedBytes, ReceivedBroadcastPackets, ReceivedUnicastPackets, SentBytes
