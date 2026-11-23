Write-Host "Escaneando rango 192.168.137.2 a 192.168.137.50..."

$tasks = @()
2..50 | ForEach-Object {
    $ip = "192.168.137.$_"
    $ping = New-Object System.Net.NetworkInformation.Ping
    $tasks += [PSCustomObject]@{
        IP = $ip
        Task = $ping.SendPingAsync($ip, 150)
    }
}

[System.Threading.Tasks.Task]::WaitAll($tasks.Task)

$found = @()
foreach ($t in $tasks) {
    if ($t.Task.Result.Status -eq "Success") {
        $found += $t.IP
    }
}

if ($found.Count -gt 0) {
    Write-Host "Dispositivos que respondieron a Ping:" -ForegroundColor Green
    $found | ForEach-Object { Write-Host " -> $_" -ForegroundColor Green }
} else {
    Write-Host "Ninguna IP respondio directamente a ICMP (esperado si iLO tiene firewall activo)." -ForegroundColor Cyan
}

Write-Host "--- Tabla ARP en interfaz 192.168.137.1 ---"
arp -a -N 192.168.137.1
