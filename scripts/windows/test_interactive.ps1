$ErrorActionPreference = "Continue"
$p = New-Object System.IO.Ports.SerialPort('COM6', 115200, [System.IO.Ports.Parity]::None, 8, [System.IO.Ports.StopBits]::One)
$p.DtrEnable = $true
$p.RtsEnable = $true
$p.ReadTimeout = 2000
$p.WriteTimeout = 1000

try {
    $p.Open()
    Write-Host "COM6 opened."
    $p.DiscardInBuffer()
    $p.DiscardOutBuffer()

    Write-Host "Sending Enter..."
    $p.WriteLine("")
    Start-Sleep -Milliseconds 800
    
    $p.WriteLine("root")
    Start-Sleep -Milliseconds 800
    
    $p.WriteLine("")
    Start-Sleep -Milliseconds 1000

    $buf = $p.ReadExisting()
    Write-Host ("Bytes read: " + $buf.Length)
    if ($buf) {
        Write-Host "=== RECEIVED FROM COM6 ==="
        Write-Host $buf
    } else {
        Write-Host "No bytes received on COM6 at 115200."
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    if ($p.IsOpen) { $p.Close() }
}
