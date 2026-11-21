$ErrorActionPreference = 'Continue'
$port = 'COM5'
$deadline = (Get-Date).AddSeconds(150)
$buf = New-Object System.Text.StringBuilder
$sp = $null

while ((Get-Date) -lt $deadline) {
    if (-not $sp) {
        $names = [System.IO.Ports.SerialPort]::GetPortNames()
        if ($names -notcontains $port) {
            Write-Host ("[{0:HH:mm:ss}] {1} not present (ports: {2})" -f (Get-Date), $port, ($names -join ','))
            Start-Sleep -Seconds 3
            continue
        }
        try {
            $sp = New-Object System.IO.Ports.SerialPort($port, 115200, [System.IO.Ports.Parity]::None, 8, [System.IO.Ports.StopBits]::One)
            $sp.DtrEnable = $true
            $sp.RtsEnable = $true
            $sp.ReadTimeout = 500
            $sp.WriteTimeout = 500
            $sp.Open()
            Write-Host ("[{0:HH:mm:ss}] opened {1}" -f (Get-Date), $port)
        } catch {
            Write-Host ("open failed: " + $_.Exception.Message)
            $sp = $null
            Start-Sleep -Seconds 3
            continue
        }
    }
    try {
        $n = $sp.BytesToRead
        if ($n -gt 0) {
            $chunk = $sp.ReadExisting()
            [void]$buf.Append($chunk)
            Write-Host ("[{0:HH:mm:ss}] RX {1} bytes" -f (Get-Date), $chunk.Length)
            Write-Host $chunk
        } else {
            $sp.Write("`r")
        }
    } catch {
        Write-Host ("read error: " + $_.Exception.Message)
        try { $sp.Close() } catch {}
        $sp = $null
        Start-Sleep -Seconds 2
        continue
    }
    Start-Sleep -Milliseconds 900
}
if ($sp) { try { $sp.Close() } catch {} }
Write-Host ("=== TOTAL " + $buf.Length + " bytes ===")
