$ErrorActionPreference = "Continue"
$p = New-Object System.IO.Ports.SerialPort('COM6', 115200, [System.IO.Ports.Parity]::None, 8, [System.IO.Ports.StopBits]::One)
$p.DtrEnable = $false
$p.RtsEnable = $false
$p.ReadTimeout = 1000
$p.WriteTimeout = 1000

try {
    $p.Open()
    Write-Host "Opened COM6."
    
    # Check if any bytes in buffer
    $b = $p.ReadExisting()
    if ($b) { Write-Host ("Initial buffer: " + $b) }
    
    # Send newline to wake up login prompt
    Write-Host "Sending newline to COM6..."
    $p.Write("`r`n")
    Start-Sleep -Milliseconds 500
    $resp = $p.ReadExisting()
    Write-Host ("Response: '" + $resp + "'")
    
    if (-not $resp) {
        Write-Host "Sending second newline..."
        $p.Write("`r`n")
        Start-Sleep -Milliseconds 800
        $resp2 = $p.ReadExisting()
        Write-Host ("Response 2: '" + $resp2 + "'")
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    if ($p.IsOpen) { $p.Close() }
}
