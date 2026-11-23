# Setup PXE Environment for AlmaLinux 9 Headless Installation
$ErrorActionPreference = "Stop"

$pxeRoot = "C:\Users\lenin\pxeboot"
$tftpDir = Join-Path $pxeRoot "tftp"
$wwwDir = Join-Path $pxeRoot "www"
$toolsDir = Join-Path $pxeRoot "tools"

foreach ($dir in @($pxeRoot, $tftpDir, $wwwDir, $toolsDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

Write-Host "1. Descargando iPXE bootloader (undionly.kpxe)..." -ForegroundColor Cyan
$undionlyPath = Join-Path $tftpDir "undionly.kpxe"
if (-not (Test-Path $undionlyPath)) {
    & curl.exe -L --connect-timeout 10 --max-time 60 -o $undionlyPath "http://boot.ipxe.org/undionly.kpxe"
}
Write-Host "   -> undionly.kpxe listo ($((Get-Item $undionlyPath).Length) bytes)" -ForegroundColor Green

Write-Host "2. Descargando Tftpd64 portable..." -ForegroundColor Cyan
$tftpdZip = Join-Path $toolsDir "tftpd64.zip"
$tftpdExe = Join-Path $toolsDir "tftpd64.exe"
if (-not (Test-Path $tftpdExe)) {
    & curl.exe -L --connect-timeout 10 --max-time 60 -o $tftpdZip "https://github.com/PJO2/tftpd64/releases/download/v4.74/tftpd64_portable_v4.74.zip"
    Expand-Archive -Path $tftpdZip -DestinationPath $toolsDir -Force
}
Write-Host "   -> Tftpd64 listo en $toolsDir" -ForegroundColor Green

Write-Host "3. Copiando kernel e initrd al directorio web..." -ForegroundColor Cyan
$almaroot = "C:\Users\lenin\pxeboot\almalinux9"
Copy-Item (Join-Path $almaroot "vmlinuz") (Join-Path $wwwDir "vmlinuz") -Force
Copy-Item (Join-Path $almaroot "initrd.img") (Join-Path $wwwDir "initrd.img") -Force
Write-Host "   -> Archivos web copiados con exito" -ForegroundColor Green

Write-Host "4. Generando script iPXE (boot.ipxe)..." -ForegroundColor Cyan
$ipxeScript = @"
#!ipxe
echo ========================================================
echo   Xeon Nexus Sentinel - AlmaLinux 9 Headless Netboot
echo ========================================================

set base-url http://192.168.137.1:8000

echo Descargando kernel de AlmaLinux 9 (vmlinuz)...
kernel `${base-url}/vmlinuz initrd=initrd.img inst.repo=https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/ inst.ks=`${base-url}/ks.cfg inst.text ip=dhcp console=tty0 console=ttyS0,115200n8

echo Descargando ramdisk de AlmaLinux 9 (initrd.img)...
initrd `${base-url}/initrd.img

echo Iniciando instalacion desatendida...
boot
"@
Set-Content -Path (Join-Path $wwwDir "boot.ipxe") -Value $ipxeScript -Encoding ASCII

Write-Host "5. Generando archivo Kickstart headless desatendido (ks.cfg)..." -ForegroundColor Cyan
$ksConfig = @"
# AlmaLinux 9 Kickstart - Instalacion Desatendida Headless para HP ProLiant ML150 G6
text
skipx
firstboot --disabled
eula --agreed

lang en_US.UTF-8
keyboard us
timezone America/Mexico_City --utc

# Red automatica por DHCP en la interfaz conectada
network --bootproto=dhcp --device=link --activate --onboot=yes --hostname=xeon-nexus-sentinel

# Fuente de instalacion oficial de AlmaLinux 9
url --url="https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/"

# Contrasena de root: nexusadmin2026!
rootpw --plaintext nexusadmin2026!

# Configuracion de Firewall y SELinux
firewall --enabled --service=ssh
selinux --enforcing

# Particionamiento automatico en disco MBR/BIOS
bootloader --location=mbr
zerombr
clearpart --all --initlabel
autopart --type=plain

# Paquetes minimos para servidor headless
%packages
@^minimal-environment
openssh-server
openssh-clients
curl
wget
tar
rsync
pciutils
lsscsi
net-tools
%end

services --enabled="sshd,NetworkManager"

# Post-instalacion: permitir login root por SSH
%post --log=/root/ks-post.log
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config.d/01-permitroot.conf
systemctl enable sshd
%end

# Reiniciar automaticamente al terminar la instalacion
reboot
"@
Set-Content -Path (Join-Path $wwwDir "ks.cfg") -Value $ksConfig -Encoding ASCII

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "   Entorno PXE / HTTP / Kickstart configurado con exito   " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Get-ChildItem $wwwDir | Format-Table Name, Length, LastWriteTime -AutoSize
