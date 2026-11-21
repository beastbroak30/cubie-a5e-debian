$sw = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "=== SCANNING FOR USB GADGET (RNDIS / ACM / RADXA) ==="

while ($sw.Elapsed.TotalSeconds -lt 25) {
    $devs = Get-PnpDevice -PresentOnly | Where-Object { 
        $_.FriendlyName -match "Gadget|Radxa|RNDIS|USB Serial|CDC|Linux" -or
        $_.InstanceId -match "1D6B"
    }
    if ($devs) {
        Write-Host "FOUND DEVICE(S):"
        $devs | Format-Table InstanceId, Class, FriendlyName, Status
        break
    }
    Start-Sleep -Seconds 2
}

if (-not $devs) {
    Write-Host "No new gadget device detected yet. Current USB network adapters:"
    Get-NetAdapter | Format-Table Name, InterfaceDescription, Status, LinkSpeed
}
