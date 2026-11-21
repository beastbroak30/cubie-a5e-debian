$ErrorActionPreference = "Continue"

Write-Host "=== CONNECTING TO LINUX LOGIN ON COM5 (USB SERIAL GADGET) ==="
$p = New-Object System.IO.Ports.SerialPort('COM5', 115200, [System.IO.Ports.Parity]::None, 8, [System.IO.Ports.StopBits]::One)
$p.DtrEnable = $true
$p.RtsEnable = $true
$p.ReadTimeout = 2000
$p.WriteTimeout = 1000

try {
    $p.Open()
    Write-Host "COM5 opened successfully."
    $p.DiscardInBuffer()

    # Send Enter to prompt login
    $p.Write("`r`n")
    Start-Sleep -Milliseconds 500
    $p.Write("`r`n")
    Start-Sleep -Milliseconds 500

    $buf = $p.ReadExisting()
    Write-Host "=== CONSOLE OUTPUT ==="
    Write-Host $buf

    if ($buf -match "login:") {
        Write-Host "Sending username 'radxa'..."
        $p.Write("radxa`r`n")
        Start-Sleep -Milliseconds 800
        $buf2 = $p.ReadExisting()
        Write-Host $buf2

        if ($buf2 -match "Password:") {
            Write-Host "Sending password 'radxa'..."
            $p.Write("radxa`r`n")
            Start-Sleep -Milliseconds 1200
            $buf3 = $p.ReadExisting()
            Write-Host $buf3
            
            # Send uname -a
            $p.Write("uname -a`r`n")
            Start-Sleep -Milliseconds 600
            Write-Host ($p.ReadExisting())
        }
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    if ($p.IsOpen) { $p.Close() }
}
