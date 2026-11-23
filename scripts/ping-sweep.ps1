Write-Host "Realizando ping sweep rapido en 192.168.137.0/24..."
1..30 | ForEach-Object -Parallel {
    $ip = "192.168.137.$_"
    $p = New-Object System.Net.NetworkInformation.Ping
    $null = $p.Send($ip, 100)
} -ThrottleLimit 30

Start-Sleep -Milliseconds 500
arp -a -N 192.168.137.1
