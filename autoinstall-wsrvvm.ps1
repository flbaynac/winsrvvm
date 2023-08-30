<#
.NOTES
    Author         : Facundo Baynac facundobaynac.com.ar
    GitHub         : https://github.com/flbaynac
    License        : MIT
#>

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Output "Se necesita permisos de administrador para habilitar las características. Re-lanzando con permisos."
    Start-Process -Verb runas -FilePath powershell.exe -ArgumentList "iwr -useb https://raw.githubusercontent.com/flbaynac/winsrvvm/main/autoinstall-wsrvvm.ps1 | iex"
    break
}

"Habilitando Hyper-v (Debe reiniciar una vez instalada la caracteristica)"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

"Descargando Windows Server 2022 Trial"
cd C:
iwr -useb https://go.microsoft.com/fwlink/p/?linkid=2195333 -OutFile wsrv2022.iso

"Creando la maquina virtual"
$VMName = "WINSRV2022SO2"
$Switch = 'External VM Switch'
$InstallMedia = '.\wsrv2022.iso'
New-VM -Name $VMName -MemoryStartupBytes 2147483648 -Generation 2 -NewVHDPath "D:\Virtual Machines\$VMName\$VMName.vhdx" -NewVHDSizeBytes 42949672960 -Path "D:\Virtual Machines\$VMName" -SwitchName $Switch

# Add DVD Drive to Virtual Machine
Add-VMScsiController -VMName $VMName
Add-VMDvdDrive -VMName $VMName -ControllerNumber 1 -ControllerLocation 0 -Path $InstallMedia

# Mount Installation Media
$DVDDrive = Get-VMDvdDrive -VMName $VMName

# Configure Virtual Machine to Boot from DVD
Set-VMFirmware -VMName $VMName -FirstBootDevice $DVDDrive

# Activar virtualización anidada
Set-VMProcessor -VMName $VMName -ExposeVirtualizationExtensions $True

"Abra el Administrador de Hyper-v y arranque la maquina virtual, siga los pasos del instalador del sistema"
