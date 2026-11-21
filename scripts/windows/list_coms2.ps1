$ErrorActionPreference = 'Continue'
Write-Host "=== PORTS ==="
Get-PnpDevice -Class Ports -PresentOnly | Format-Table InstanceId, FriendlyName, Status -AutoSize
Write-Host "=== 1D6B CHILDREN ==="
Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -like "*1D6B*" } | Format-Table InstanceId, Class, FriendlyName, Status -AutoSize
