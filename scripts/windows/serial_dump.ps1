$log = 'C:\Users\akant\AppData\Local\Temp\opencode\serial.log'
if (-not (Test-Path $log)) { Write-Host "no log"; exit }
$len = (Get-Item $log).Length
Write-Host ("=== serial.log: " + $len + " bytes, mtime " + (Get-Item $log).LastWriteTime + " ===")
Get-Content $log -Raw
Write-Host ""
Write-Host "=== ports in use ==="
[System.IO.Ports.SerialPort]::GetPortNames() | ForEach-Object { Write-Host $_ }
