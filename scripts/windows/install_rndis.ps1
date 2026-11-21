$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',$PSCommandPath
    exit 0
}

$log = 'C:\Users\akant\AppData\Local\Temp\opencode\install_rndis.log'
Start-Transcript -Path $log -Force | Out-Null

$devId = "USB\VID_1D6B&PID_0104&MI_00\6&202b6536&0&0000"
$infPath = "C:\Windows\System32\DriverStore\FileRepository\netrndis.inf_amd64_cfadd82b034011c6\netrndis.inf"

Write-Host "=== INSTALLING MICROSOFT RNDIS DRIVER ==="
pnputil /add-driver $infPath /install

Write-Host "=== UPDATING DEVICE WITH INF ==="
pnputil /scan-devices
Start-Sleep -Seconds 2

Get-PnpDevice | Where-Object { $_.InstanceId -like "*1D6B*MI_00*" } | Format-List InstanceId, FriendlyName, Class, Status

Stop-Transcript | Out-Null
