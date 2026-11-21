Start-Sleep -Seconds 35
Write-Host '=== USB 1D6B DEVICES ==='
Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -like '*1D6B*' } | Format-Table InstanceId,Class,FriendlyName,Status -AutoSize
Write-Host '=== NET ADAPTERS ==='
Get-NetAdapter | Format-Table Name,InterfaceDescription,Status,MacAddress -AutoSize
Write-Host '=== IP ==='
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like '10.55.*' -or $_.IPAddress -like '169.254.*' } | Format-Table InterfaceAlias,IPAddress,PrefixLength -AutoSize
