$ErrorActionPreference = "Continue"

Write-Host "=== TESTING HARDWARE UART ON COM6 (ttyAS0 @ 115200 8N1) ==="
$p = New-Object System.IO.Ports.SerialPort('COM6', 115200, [System.IO.Ports.Parity]::None, 8, [System.IO.Ports.StopBits]::One)
$p.DtrEnable = $true
$p.RtsEnable = $true
$p.ReadTimeout = 2000
$p.WriteTimeout = 1000

try {
    $p.Open()
    Write-Host "COM6 opened successfully."
    $p.DiscardInBuffer()

    # Send multiple newlines to wake up getty
    $p.Write("`r`n")
    Start-Sleep -Milliseconds 300
    $p.Write("`r`n")
    Start-Sleep -Milliseconds 500

    $buf = $p.ReadExisting()
    Write-Host "=== COM6 READOUT ==="
    Write-Host ("Length: " + $buf.Length)
    if ($buf) {
        Write-Host $buf
    } else {
        Write-Host "No immediate buffer. Listening for 3 seconds..."
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        while ($sw.Elapsed.TotalSeconds -lt 3) {
            $c = $p.ReadExisting()
            if ($c) { Write-Host $c -NoNewline }
            Start-Sleep -Milliseconds 150
        }
    }
} catch {
    Write-Host "COM6 Error: $($_.Exception.Message)"
} finally {
    if ($p.IsOpen) { $p.Close() }
}
