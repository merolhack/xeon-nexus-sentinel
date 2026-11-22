# Script de auditoría de Windows 11 para Xeon-Nexus-Sentinel
Write-Host "==================== 1. RED E INTERFACES ====================" -ForegroundColor Cyan
Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, LinkSpeed, MacAddress | Format-Table -AutoSize
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254*" } | Select-Object InterfaceAlias, IPAddress, PrefixLength | Format-Table -AutoSize
Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Select-Object InterfaceAlias, NextHop | Format-Table -AutoSize

Write-Host "==================== 2. ESPECIFICACIONES DE HARDWARE ====================" -ForegroundColor Cyan
Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer, Model | Format-Table -AutoSize
Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed, VirtualizationFirmwareEnabled | Format-Table -AutoSize
$os = Get-CimInstance Win32_OperatingSystem
[PSCustomObject]@{
    OS           = $os.Caption
    Version      = $os.Version
    Build        = $os.BuildNumber
    Arquitectura = $os.OSArchitecture
    RAM_Total_GB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    RAM_Libre_GB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
} | Format-List

Get-CimInstance Win32_VideoController | Select-Object Name, DriverVersion, @{Name="VRAM_MB";Expression={[math]::Round($_.AdapterRAM/1MB,2)}} | Format-Table -AutoSize
Get-Volume | Where-Object { $_.DriveType -eq 'Fixed' } | Select-Object DriveLetter, FileSystemType, @{Name="Size_GB";Expression={[math]::Round($_.Size/1GB,2)}}, @{Name="FreeSpace_GB";Expression={[math]::Round($_.SizeRemaining/1GB,2)}} | Format-Table -AutoSize

Write-Host "==================== 3. STACK DE DESARROLLO INSTALADO ====================" -ForegroundColor Cyan
$tools = @("git", "node", "npm", "pnpm", "python", "ollama", "ssh", "docker", "wsl", "code", "gh", "winget")
$results = foreach ($tool in $tools) {
    $cmd = Get-Command $tool -ErrorAction SilentlyContinue
    if ($cmd) {
        [PSCustomObject]@{ Herramienta = $tool; Instalado = $true; Ruta = $cmd.Source }
    } else {
        [PSCustomObject]@{ Herramienta = $tool; Instalado = $false; Ruta = "No encontrado" }
    }
}
$results | Format-Table -AutoSize

Write-Host "==================== 4. ESTADO DE WSL Y VIRTUALIZACIÓN ====================" -ForegroundColor Cyan
wsl --list --verbose
wsl --status

Write-Host "==================== 5. PRIVILEGIOS Y POLÍTICAS ====================" -ForegroundColor Cyan
[PSCustomObject]@{
    EsAdmin              = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    ExecutionPolicyLocal = (Get-ExecutionPolicy)
} | Format-List
