<#
.SYNOPSIS
    Habilita Conexión Compartida a Internet (ICS) desde Wi-Fi hacia Ethernet.
    Requiere ejecutarse en una ventana de PowerShell como Administrador.
#>
$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Habilitando Internet Connection Sharing (Wi-Fi -> Ethernet) " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Este script requiere privilegios de Administrador para modificar la configuracion de red."
    Write-Host "Por favor abre PowerShell haciendo clic derecho -> 'Ejecutar como administrador' y ejecuta:" -ForegroundColor Yellow
    Write-Host "powershell -ExecutionPolicy Bypass -File .\scripts\enable-ics.ps1" -ForegroundColor White
    exit 1
}

try {
    $netShare = New-Object -ComObject HNetCfg.HNetShare
    $wifiConn = $null
    $ethConn = $null

    foreach ($c in $netShare.EnumEveryConnection) {
        $props = $netShare.NetConnectionProps($c)
        if ($props.Name -eq "Wi-Fi") { $wifiConn = $c }
        if ($props.Name -eq "Ethernet") { $ethConn = $c }
    }

    if (-not $wifiConn) {
        Write-Error "No se encontro el adaptador 'Wi-Fi'."
        exit 1
    }
    if (-not $ethConn) {
        Write-Error "No se encontro el adaptador 'Ethernet'."
        exit 1
    }

    $wifiConfig = $netShare.INetSharingConfigurationForINetConnection($wifiConn)
    $ethConfig = $netShare.INetSharingConfigurationForINetConnection($ethConn)

    # 0 = Public (conecta a Internet)
    # 1 = Private (recibe DHCP y red local)
    $wifiConfig.EnableSharing(0)
    $ethConfig.EnableSharing(1)

    Write-Host "Internet Connection Sharing (ICS) activado exitosamente." -ForegroundColor Green
    Write-Host "Tu tarjeta Ethernet ahora tiene asignada la IP 192.168.137.1." -ForegroundColor Cyan
    Write-Host "El servidor HP recibira una IP automatica por DHCP." -ForegroundColor Green
} catch {
    Write-Error "Error al configurar ICS: $($_.Exception.Message)"
}
