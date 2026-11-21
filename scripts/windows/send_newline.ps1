$p = New-Object System.IO.Ports.SerialPort('COM5', 115200, [System.IO.Ports.Parity]::None, 8, [System.IO.Ports.StopBits]::One)
$p.DtrEnable = $true
$p.RtsEnable = $true
$p.ReadTimeout = 1000

try {
    $p.Open()
    $p.DiscardInBuffer()

    # Send 4 newlines
    1..4 | ForEach-Object {
        $p.Write("`n")
        Start-Sleep -Milliseconds 200
    }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    while ($sw.Elapsed.TotalSeconds -lt 4) {
        $s = $p.ReadExisting()
        if ($s) { Write-Host $s -NoNewline }
        Start-Sleep -Milliseconds 100
    }
} finally {
    if ($p.IsOpen) { $p.Close() }
}
