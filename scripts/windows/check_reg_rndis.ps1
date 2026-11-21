$ErrorActionPreference = 'Stop'
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\fix_rndis_compat.log'

Start-Transcript -Path $log -Force | Out-Null
Write-Host "=== CONFIGURING USB RNDIS COMPATIBLE IDS IN REGISTRY ==="

$regPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\USB\VID_1D6B&PID_0104&MI_00\6&202B6536&0&0000"
if (Test-Path $regPath) {
    Write-Host "Found device key in registry."
    $compat = (Get-ItemProperty -Path $regPath -Name CompatibleIDs -ErrorAction SilentlyContinue).CompatibleIDs
    Write-Host ("Current CompatibleIDs: " + ($compat -join ", "))
}

# The canonical way Windows binds generic USB RNDIS without unsigned driver INF:
# Match the device interface in USB driver store
$oemInfs = Get-ChildItem C:\Windows\INF\oem*.inf -ErrorAction SilentlyContinue | Where-Object {
    Select-String -Path $_.FullName -Pattern "RNDIS" -Quiet -ErrorAction SilentlyContinue
}
Write-Host ("Existing OEM RNDIS infs: " + $oemInfs.Count)

Stop-Transcript | Out-Null
