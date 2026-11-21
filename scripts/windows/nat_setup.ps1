$ErrorActionPreference = 'Continue'
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\nat_setup.log'
Start-Transcript -Path $log -Force | Out-Null

Write-Host '=== BEFORE ==='
Get-NetAdapter -Name 'Ethernet 5' | Format-Table Name,Status,InterfaceIndex -AutoSize
Get-NetIPAddress -InterfaceAlias 'Ethernet 5' -AddressFamily IPv4 | Format-Table IPAddress,PrefixLength,PrefixOrigin -AutoSize

# remove any previous NAT with our name
Get-NetNat -Name 'CubieUSB' -ErrorAction SilentlyContinue | Remove-NetNat -Confirm:$false
Write-Host '=== static IP on USB link (Windows side) ==='
Set-NetIPInterface -InterfaceAlias 'Ethernet 5' -Dhcp Disabled -ErrorAction SilentlyContinue
Get-NetIPAddress -InterfaceAlias 'Ethernet 5' -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object { $_.PrefixOrigin -ne 'Manual' } |
    Remove-NetIPAddress -Confirm:$false -ErrorAction SilentlyContinue
if (-not (Get-NetIPAddress -InterfaceAlias 'Ethernet 5' -IPAddress '10.55.0.2' -ErrorAction SilentlyContinue)) {
    New-NetIPAddress -InterfaceAlias 'Ethernet 5' -IPAddress '10.55.0.2' -PrefixLength 24 | Out-Null
}
Write-Host '=== enable forwarding + NAT ==='
Set-NetIPInterface -InterfaceAlias 'Ethernet 5' -Forwarding Enabled -ErrorAction SilentlyContinue
New-NetNat -Name 'CubieUSB' -InternalIPInterfaceAddressPrefix '10.55.0.0/24' | Out-Null

Write-Host '=== AFTER ==='
Get-NetIPAddress -InterfaceAlias 'Ethernet 5' -AddressFamily IPv4 | Format-Table IPAddress,PrefixLength -AutoSize
Get-NetNat | Format-Table Name,InternalIPInterfaceAddressPrefix,Active -AutoSize
Write-Host '=== ping board ==='
Test-Connection -ComputerName 10.55.0.1 -Count 2 -Quiet
Stop-Transcript | Out-Null
