$ErrorActionPreference = "Continue"

Write-Host "=== TESTING COM6 AT ALL COMMON BAUD RATES ==="
$bauds = @(115200, 1500000, 921600, 57600, 38400, 9600)

foreach ($b in $bauds) {
    try {
        $p = New-Object System.IO.Ports.SerialPort('COM6', $b, [System.IO.Ports.Parity]::None, 8, [System.IO.Ports.StopBits]::One)
        $p.ReadTimeout = 400
        $p.Open()
        $p.DiscardInBuffer()
        $p.Write("`r`n")
        Start-Sleep -Milliseconds 250
        $s = $p.ReadExisting()
        if ($s -and $s.Trim().Length -gt 0) {
            Write-Host "!!! RECEIVED DATA AT BAUD $b !!!"
            Write-Host $s
            $p.Close()
            break
        }
        $p.Close()
    } catch {}
}
Write-Host "Baud sweep finished."
