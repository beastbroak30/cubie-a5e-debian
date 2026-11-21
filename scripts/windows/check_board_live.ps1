Write-Host "=== SERIAL LOG STATUS ==="
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\serial.log'
if (Test-Path $log) {
    Write-Host ("serial.log length: {0} bytes, mtime: {1}" -f (Get-Item $log).Length, (Get-Item $log).LastWriteTime)
    Get-Content $log -Tail 30
} else {
    Write-Host "serial.log does not exist"
}

Write-Host "`n=== NETWORK ADAPTERS (looking for USB-C Ethernet 10.55.0.x / RNDIS) ==="
Get-NetAdapter | Select-Object Name,InterfaceDescription,Status,LinkSpeed | Format-Table -AutoSize
Get-NetIPAddress -InterfaceAlias "*" -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object InterfaceAlias,IPAddress,PrefixLength | Format-Table -AutoSize

Write-Host "`n=== USB DEVICES ENUMERATED (usbipd / PnP) ==="
usbipd list 2>$null

Write-Host "`n=== COM PORTS ==="
[System.IO.Ports.SerialPort]::GetPortNames() | ForEach-Object { Write-Host $_ }
