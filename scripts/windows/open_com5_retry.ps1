$ErrorActionPreference = 'Continue'

# Try to open COM5 with retry
$port = 'COM5'
Write-Host "=== ATTEMPTING COM5 OPEN (retry loop) ==="
$ok = $false
for ($i = 1; $i -le 6; $i++) {
    try {
        $sp = New-Object System.IO.Ports.SerialPort($port, 115200, [System.IO.Ports.Parity]::None, 8, [System.IO.Ports.StopBits]::One)
        $sp.DtrEnable = $true
        $sp.RtsEnable = $true
        $sp.ReadTimeout = 800
        $sp.WriteTimeout = 800
        $sp.Open()
        Write-Host "COM5 opened on attempt $i"
        $sp.DiscardInBuffer()
        $sp.Write("`r`n")
        Start-Sleep -Milliseconds 600
        $sp.Write("`r`n")
        Start-Sleep -Milliseconds 600
        $data = $sp.ReadExisting()
        Write-Host ("RECEIVED LEN=" + $data.Length)
        if ($data.Length -gt 0) { Write-Host $data }
        $sp.Close()
        $ok = $true
        break
    } catch {
        Write-Host ("Attempt $i failed: " + $_.Exception.Message)
        Start-Sleep -Seconds 2
    }
}
if (-not $ok) { Write-Host "COM5 could not be opened." }
