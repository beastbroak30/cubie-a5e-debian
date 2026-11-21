$ErrorActionPreference = 'Stop'
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\bind_rndis.log'

Start-Transcript -Path $log -Force | Out-Null
Write-Host "=== CREATING RNDIS OEM DRIVER INF ==="

# We create an INF that matches USB\VID_1D6B&PID_0104&MI_00 specifically to Microsoft RNDIS6
$infDir = 'C:\Users\akant\AppData\Local\Temp\opencode\rndis_oem'
New-Item -ItemType Directory -Force -Path $infDir | Out-Null
$infFile = Join-Path $infDir 'radxa_rndis.inf'

$infContent = @"
;
; Radxa Cubie A5E RNDIS Setup File
;

[Version]
Signature           = "`$Windows NT`$"
Class               = Net
ClassGUID           = {4d36e972-e325-11ce-bfc1-08002be10318}
Provider            = %ManufacturerName%
DriverVer           = 06/21/2006,6.1.7600.16385

[Manufacturer]
%ManufacturerName% = Standard,NTamd64

[Standard.NTamd64]
%DeviceDescription% = RNDIS.Install, USB\VID_1D6B&PID_0104&MI_00

[RNDIS.Install]
Characteristics = 0x84 ; NCF_PHYSICAL | NCF_HAS_UI
BusType         = 15   ; PNPBus
*IfType         = 6    ; IF_TYPE_ETHERNET_CSMACD
AddReg          = RNDIS.Reg

[RNDIS.Reg]
HKR, Ndi,               Service,    0, "RNDISMP6"
HKR, Ndi\Interfaces,    UpperRange, 0, "ndis5"
HKR, Ndi\Interfaces,    LowerRange, 0, "ethernet"

[RNDIS.Install.Services]
AddService = RNDISMP6, 2, RNDIS.Service

[RNDIS.Service]
DisplayName     = %ServiceDescription%
ServiceType     = 1 ; SERVICE_KERNEL_DRIVER
StartType       = 3 ; SERVICE_DEMAND_START
ErrorControl    = 1 ; SERVICE_ERROR_NORMAL
ServiceBinary   = %12%\rndismp6.sys
LoadOrderGroup  = NDIS

[Strings]
ManufacturerName   = "Linux Foundation"
DeviceDescription  = "Radxa Cubie A5E USB RNDIS Adapter"
ServiceDescription = "Remote NDIS 6.0 Driver"
"@

Set-Content -Path $infFile -Value $infContent -Encoding ASCII
Write-Host "INF written to $infFile"

Write-Host "=== INSTALLING OEM RNDIS DRIVER ==="
pnputil /add-driver $infFile /install

Write-Host "=== SCANNING FOR DEVICES ==="
pnputil /scan-devices
Start-Sleep -Seconds 2

Get-PnpDevice | Where-Object { $_.InstanceId -like "*1D6B*MI_00*" } | Format-List InstanceId, FriendlyName, Class, Status

Stop-Transcript | Out-Null
