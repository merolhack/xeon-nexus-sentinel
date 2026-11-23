Write-Host "Escaneando rango DHCP tipico de Windows ICS (192.168.137.100 a 192.168.137.200)..."

$tasks = @()
100..200 | ForEach-Object {
    $ip = "192.168.137.$_"
    $ping = New-Object System.Net.NetworkInformation.Ping
    $tasks += [PSCustomObject]@{
        IP = $ip
        Task = $ping.SendPingAsync($ip, 120)
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
    Write-Host ">>> DISPOSITIVOS QUE RESPONDIERON A PING <<<" -ForegroundColor Green
    $found | ForEach-Object { Write-Host " -> $_" -ForegroundColor Green }
} else {
    Write-Host "Ninguna IP respondio a ICMP directo." -ForegroundColor Cyan
}

Write-Host "--- Tabla ARP completa en 192.168.137.1 ---"
arp -a -N 192.168.137.1
