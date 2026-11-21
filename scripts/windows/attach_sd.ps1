$log = 'C:\Users\akant\AppData\Local\Temp\opencode\attach_sd.log'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Elevating usbipd attach..."
    Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',$PSCommandPath
    exit 0
}

Start-Transcript -Path $log -Force | Out-Null
Write-Host "=== BINDING & ATTACHING CARD READER (1-7) TO WSL ==="
usbipd bind --busid 1-7 -f
Start-Sleep -Seconds 1
usbipd attach --wsl --busid 1-7
Start-Sleep -Seconds 2
usbipd list
Stop-Transcript | Out-Null
