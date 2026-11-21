Write-Host '=== ping board ==='
Test-Connection -ComputerName 10.55.0.1 -Count 2 -Quiet
Write-Host '=== port 22 ==='
(Test-NetConnection -ComputerName 10.55.0.1 -Port 22 -WarningAction SilentlyContinue).TcpTestSucceeded
Write-Host '=== arp ==='
arp -a 10.55.0.1
Write-Host '=== adapter ==='
Get-NetAdapter -Name 'Ethernet 5' | Format-Table Name,Status,LinkSpeed -AutoSize
Write-Host '=== route ==='
Get-NetRoute -AddressFamily IPv4 | Where-Object { $_.DestinationPrefix -like '10.55*' } | Format-Table DestinationPrefix,NextHop,InterfaceAlias -AutoSize
