Write-Host "=== USB CONTROLLER AND HUBS CONNECTED DEVICES ==="
Get-PnpDevice -Class USB -Status OK | Select-Object FriendlyName,InstanceId | Format-Table -AutoSize

Write-Host "=== ANY DEVICES WITH WARNING / ERROR / UNKNOWN ==="
Get-PnpDevice | Where-Object { $_.Status -ne "OK" } | Select-Object Class,FriendlyName,InstanceId,Status | Format-Table -AutoSize

Write-Host "=== USB HUB DETAILS (usbipd) ==="
usbipd list
