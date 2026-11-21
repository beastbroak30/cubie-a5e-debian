Write-Host "=== ARP TABLE / NEIGHBORS (checking for cubie-a5e IP) ==="
Get-NetNeighbor -AddressFamily IPv4 | Where-Object { $_.State -ne "Unreachable" } | Select-Object IPAddress,LinkLayerAddress,InterfaceAlias,State | Format-Table -AutoSize
Write-Host "=== PINGING BROADCAST / SUBNET ==="
$subnet = "10.41.241."
1..30 | ForEach-Object {
    $ip = "$subnet$_"
    Test-Connection -ComputerName $ip -Count 1 -Quiet -TimeoutSeconds 1 | Out-Null
}
Get-NetNeighbor -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "$subnet*" } | Format-Table -AutoSize
