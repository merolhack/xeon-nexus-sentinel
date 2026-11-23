$ports = @(68, 137, 138, 623, 1900, 5353, 5355)
$foundPort = $null

foreach ($p in $ports) {
    try {
        $endpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, $p)
        $client = New-Object System.Net.Sockets.UdpClient($p)
        $client.Client.ReceiveTimeout = 600
        Write-Host "Probando escucha en puerto UDP $p..."
        $data = $client.Receive([ref]$endpoint)
        Write-Host ">>> EXITO: Paquete capturado en puerto $p desde $($endpoint.Address):$($endpoint.Port) <<<" -ForegroundColor Green
        $client.Close()
        $foundPort = $p
        break
    } catch {
        # timeout o en uso
        if ($client) { $client.Close() }
    }
}

if (-not $foundPort) {
    Write-Host "No se capturaron paquetes en los puertos estandar durante el escaneo."
}
