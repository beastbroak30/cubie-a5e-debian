$ErrorActionPreference = 'Continue'
Write-Host "=== ALL COM PORTS PRESENT ==="
Get-PnpDevice -Class Ports -PresentOnly | Format-Table InstanceId, FriendlyName, Status -AutoSize

Write-Host "=== USB GADGET CHILD DEVICES ==="
Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -like "*1D6B*" } | Format-Table InstanceId, Class, FriendlyName, Status -AutoSize
