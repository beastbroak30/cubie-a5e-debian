Get-Process powershell -ErrorAction SilentlyContinue | Select-Object Id,ProcessName,StartTime,CommandLine
Write-Host "=== TEST OPEN COM6 ==="
try {
    $p = New-Object System.IO.Ports.SerialPort('COM6', 115200, [System.IO.Ports.Parity]::None, 8, [System.IO.Ports.StopBits]::One)
    $p.Open()
    Write-Host "COM6 OPENED OK: Port is currently free and idle"
    $p.Close()
} catch {
    Write-Host "COM6 OPEN FAILED (already open by background capture or locked): $($_.Exception.Message)"
}
