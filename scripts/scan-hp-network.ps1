Write-Host "=== ESTADO DE ADAPTADOR ETHERNET ==="
$adapter = Get-NetAdapter -Name "Ethernet"
[PSCustomObject]@{
    Name = $adapter.Name
    Index = $adapter.InterfaceIndex
    Status = $adapter.Status
    LinkSpeed = $adapter.LinkSpeed
    MacAddress = $adapter.MacAddress
} | Format-Table -AutoSize

Write-Host "=== ESTADISTICAS DE TRAFICO ==="
$stats = Get-NetAdapterStatistics -Name "Ethernet"
[PSCustomObject]@{
    ReceivedBytes = $stats.ReceivedBytes
    SentBytes = $stats.SentBytes
    RxBroadcast = $stats.ReceivedBroadcastPackets
    RxMulticast = $stats.ReceivedMulticastPackets
    RxUnicast = $stats.ReceivedUnicastPackets
} | Format-Table -AutoSize

Write-Host "=== ENLACES VECINOS Y TABLA ARP (Ethernet) ==="
Get-NetNeighbor -InterfaceAlias "Ethernet" -ErrorAction SilentlyContinue | Format-Table IPAddress, LinkLayerAddress, State -AutoSize
