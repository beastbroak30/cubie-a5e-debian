$ErrorActionPreference = 'Stop'
$alias = 'Ethernet'
Get-NetIPAddress -InterfaceAlias $alias -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object { $_.PrefixOrigin -eq 'WellKnown' } |
    ForEach-Object { Remove-NetIPAddress -IPAddress $_.IPAddress -InterfaceAlias $alias -Confirm:$false -ErrorAction SilentlyContinue }
if (-not (Get-NetIPAddress -InterfaceAlias $alias -AddressFamily IPv4 -IPAddress '10.56.0.2' -ErrorAction SilentlyContinue)) {
    New-NetIPAddress -InterfaceAlias $alias -IPAddress 10.56.0.2 -PrefixLength 24 | Out-Null
}
Set-NetConnectionProfile -InterfaceAlias $alias -NetworkCategory Private -ErrorAction SilentlyContinue
Get-NetIPAddress -InterfaceAlias $alias -AddressFamily IPv4 | Select-Object IPAddress,PrefixLength,PrefixOrigin | Format-Table -AutoSize
Get-NetAdapter -Name $alias | Select-Object Name,Status,LinkSpeed | Format-Table -AutoSize
