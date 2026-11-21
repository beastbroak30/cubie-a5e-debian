$ErrorActionPreference = 'Continue'
Remove-NetIPAddress -InterfaceAlias 'Ethernet' -IPAddress 10.56.0.2 -PrefixLength 24 -Confirm:$false -ErrorAction SilentlyContinue
Start-Sleep -Seconds 4
Get-NetIPAddress -InterfaceAlias 'Ethernet' -AddressFamily IPv4 | Select-Object IPAddress,PrefixLength,PrefixOrigin | Format-Table -AutoSize
Get-NetAdapter -Name 'Ethernet' | Select-Object Name,Status,LinkSpeed | Format-Table -AutoSize
