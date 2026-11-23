$port = 67
try {
    $endpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, $port)
    $udpClient = New-Object System.Net.Sockets.UdpClient($port)
    $udpClient.Client.ReceiveTimeout = 5000
    Write-Host "Escuchando solicitudes DHCP (puerto 67) durante 5 segundos..."
    $data = $udpClient.Receive([ref]$endpoint)
    Write-Host "Detectado paquete de red desde: $($endpoint.Address):$($endpoint.Port)"
    $udpClient.Close()
} catch {
    Write-Host "Resultado de escucha: $($_.Exception.Message)"
}
