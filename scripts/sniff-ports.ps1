$portsToTest = @(67, 68, 137, 138, 161, 162, 623, 1900, 5353, 5355, 3268)

Write-Host "Escaneando puertos de difusion entrantes..."

foreach ($port in $portsToTest) {
    try {
        $udp = New-Object System.Net.Sockets.UdpClient
        $udp.Client.SetSocketOption([System.Net.Sockets.SocketOptionLevel]::Socket, [System.Net.Sockets.SocketOptionName]::ReuseAddress, $true)
        $ep = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, $port)
        $udp.Client.Bind($ep)
        $udp.Client.ReceiveTimeout = 400
        
        $buf = $udp.Receive([ref]$ep)
        Write-Host ">>> ENCONTRADO TRAFICO EN PUERTO $port <<<" -ForegroundColor Green
        Write-Host "Origen IP  : $($ep.Address)"
        Write-Host "Origen Port: $($ep.Port)"
        Write-Host "Bytes      : $($buf.Length)"
        $udp.Close()
        break
    } catch {
        if ($udp) { $udp.Close() }
    }
}
