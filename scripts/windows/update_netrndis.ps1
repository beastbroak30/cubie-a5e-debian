$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',$PSCommandPath
    exit 0
}

$devId = "USB\VID_1D6B&PID_0104&MI_00\6&202B6536&0&0000"
$inf = "C:\Windows\INF\netrndis.inf"

Write-Host "Updating device driver with signed netrndis.inf..."
pnputil /update-device $devId /install $inf
Start-Sleep -Seconds 2
Get-PnpDevice | Where-Object { $_.InstanceId -like "*1D6B*MI_00*" } | Format-List InstanceId, FriendlyName, Class, Status
