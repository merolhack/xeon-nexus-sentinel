try {
    $netShare = New-Object -ComObject HNetCfg.HNetShare
    Write-Host "HNetCfg.HNetShare COM cargado exitosamente."
    $connections = $netShare.EnumEveryConnection
    Write-Host "Total conexiones encontradas: $($connections.Count)"
    foreach ($c in $connections) {
        $props = $netShare.NetConnectionProps($c)
        Write-Host "Conexion: $($props.Name) | GUID: $($props.Guid)"
    }
} catch {
    Write-Host "Error al consultar HNetShare: $($_.Exception.Message)"
}
