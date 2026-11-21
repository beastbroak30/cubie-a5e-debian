Write-Host "=== CURRENT PORTS ==="
[System.IO.Ports.SerialPort]::GetPortNames() | ForEach-Object { Write-Host $_ }
Write-Host "=== PNP SERIAL DEVICES ==="
Get-PnpDevice -Class Ports -Status OK | Select-Object FriendlyName,InstanceId | Format-Table -AutoSize
