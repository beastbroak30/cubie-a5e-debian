$ErrorActionPreference = "Continue"

Write-Host "=== TESTING COM6 INTERACTION ==="
$p = New-Object System.IO.Ports.SerialPort('COM6', 115200, [System.IO.Ports.Parity]::None, 8, [System.IO.Ports.StopBits]::One)
$p.DtrEnable = $true
$p.RtsEnable = $true
$p.ReadTimeout = 1500
$p.WriteTimeout = 1000

try {
    $p.Open()
    Write-Host "COM6 opened successfully."
    $p.DiscardInBuffer()

    # Send a few carriage returns
    Write-Host "Sending Enter..."
    $p.Write("`r`n")
    Start-Sleep -Milliseconds 400
    $p.Write("`r`n")
    Start-Sleep -Milliseconds 600

    $buf = $p.ReadExisting()
    Write-Host ("Immediate response length: " + $buf.Length)
    if ($buf) {
        Write-Host "=== CONSOLE OUTPUT ==="
        Write-Host $buf
    } else {
        Write-Host "No immediate response. Listening for 4 seconds for any activity..."
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        while ($sw.Elapsed.TotalSeconds -lt 4) {
            $c = $p.ReadExisting()
            if ($c) { Write-Host $c -NoNewline }
            Start-Sleep -Milliseconds 200
        }
    }
} catch {
    Write-Host "COM6 Error: $($_.Exception.Message)"
} finally {
    if ($p.IsOpen) { $p.Close() }
}
