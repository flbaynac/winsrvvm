<#
.NOTES
    Author         : Facundo Baynac facundobaynac.com.ar
    GitHub         : https://github.com/flbaynac
    Version        : 00.01
    License        : MIT
#>

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Output "Winutil needs to be run as Administrator. Attempting to relaunch."
    Start-Process -Verb runas -FilePath powershell.exe -ArgumentList "iwr -useb https://raw.githubusercontent.com/flbaynac/winsrvvm/main/autoinstall-wsrvvm.ps1 | iex"
    break
}

# Habilitad Hyper-v
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

# Download Windows Server 2022 Trial
iwr -useb https://go.microsoft.com/fwlink/p/?linkid=2195333

# Set VM Name, Switch Name, and Installation Media Path.
$VMName = "WINSRV2022SO2"
$Switch = 'External VM Switch'

$InstallMedia = '.\20348.1.210507-1500.fe_release_amd64fre_SERVER_LOF_PACKAGES_OEM.iso'

# Create New Virtual Machine
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