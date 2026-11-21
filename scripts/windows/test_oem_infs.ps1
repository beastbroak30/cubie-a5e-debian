$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',$PSCommandPath
    exit 0
}

$log = 'C:\Users\akant\AppData\Local\Temp\opencode\bind_oem_rndis.log'
Start-Transcript -Path $log -Force | Out-Null

$devId = "USB\VID_1D6B&PID_0104&MI_00\6&202B6536&0&0000"

# Test matching each OEM inf to this device
Get-ChildItem C:\Windows\INF\oem*.inf | ForEach-Object {
    if (Select-String -Path $_.FullName -Pattern "RNDISMP6" -Quiet -ErrorAction SilentlyContinue) {
        Write-Host "Found matching RNDIS INF: $($_.Name)"
        pnputil /update-device $devId /install $_.FullName
    }
}

Start-Sleep -Seconds 2
Get-PnpDevice | Where-Object { $_.InstanceId -like "*1D6B*MI_00*" } | Format-List InstanceId, FriendlyName, Class, Status

Stop-Transcript | Out-Null
