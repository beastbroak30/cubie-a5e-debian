$ErrorActionPreference = "Continue"
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\serial.log'
Remove-Item $log -Force -ErrorAction SilentlyContinue

$p = New-Object System.IO.Ports.SerialPort('COM6', 115200, [System.IO.Ports.Parity]::None, 8, [System.IO.Ports.StopBits]::One)
$p.DtrEnable = $false
$p.RtsEnable = $false
$p.ReadTimeout = 500
$p.WriteTimeout = 1000

try {
    $p.Open()
} catch {
    "OPEN FAILED COM6: $($_.Exception.Message)" | Out-File -FilePath $log -Encoding ascii
    exit 1
}

$fs = [System.IO.File]::Open($log, [System.IO.FileMode]::Append, [System.IO.FileAccess]::Write, [System.IO.FileShare]::ReadWrite)
$w  = New-Object System.IO.StreamWriter($fs)
$w.AutoFlush = $true
$w.Write("=== capture start $(Get-Date -Format o) COM6 115200 8N1 DTR=off RTS=off ===`r`n")

$sw = [System.Diagnostics.Stopwatch]::StartNew()
try {
    while ($sw.Elapsed.TotalSeconds -lt 3600) {
        try { $s = $p.ReadExisting() } catch { $s = '' }
        if ($s -and $s.Length -gt 0) { $w.Write($s) }
        Start-Sleep -Milliseconds 120
    }
} finally {
    $w.Write("`r`n=== capture stop $(Get-Date -Format o) ===`r`n")
    $w.Dispose()
    $fs.Dispose()
    try { $p.Close() } catch {}
}
