$ErrorActionPreference = "Continue"

Write-Host "=== FINDING CP210x ADAPTER ==="
$dev = Get-PnpDevice -Class Ports -Status OK | Where-Object { $_.FriendlyName -like "*CP210*" -or $_.FriendlyName -like "*UART*" -or $_.FriendlyName -like "*USB Serial*" }
$dev | Format-Table -AutoSize

$portName = $null
if ($dev -and $dev.FriendlyName -match '\((COM\d+)\)') {
    $portName = $matches[1]
    Write-Host "Detected adapter on port: $portName"
} else {
    # fallback check port names
    $ports = [System.IO.Ports.SerialPort]::GetPortNames() | Where-Object { $_ -notin @('COM3','COM4','COM7','COM8') }
    if ($ports) { $portName = $ports[0]; Write-Host "Fallback detected port: $portName" }
}

if (-not $portName) {
    Write-Host "No USB serial adapter detected! All ports: " + (([System.IO.Ports.SerialPort]::GetPortNames()) -join ', ')
    exit 1
}

Write-Host "=== CONNECTING TO $portName AT 115200 8N1 ==="
$p = New-Object System.IO.Ports.SerialPort($portName, 115200, [System.IO.Ports.Parity]::None, 8, [System.IO.Ports.StopBits]::One)
$p.DtrEnable = $true
$p.RtsEnable = $true
$p.ReadTimeout = 2000
$p.WriteTimeout = 1000

try {
    $p.Open()
    Write-Host "Port $portName opened."
    $p.DiscardInBuffer()

    # Send multiple enters to wake getty
    $p.WriteLine("")
    Start-Sleep -Milliseconds 400
    $p.WriteLine("")
    Start-Sleep -Milliseconds 600

    $buf = $p.ReadExisting()
    Write-Host ("Bytes read: " + $buf.Length)
    if ($buf) {
        Write-Host "=== CONSOLE OUTPUT ==="
        Write-Host $buf
    } else {
        Write-Host "No response to Enter. Listening for 5 seconds..."
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        while ($sw.Elapsed.TotalSeconds -lt 5) {
            $c = $p.ReadExisting()
            if ($c) { Write-Host $c -NoNewline }
            Start-Sleep -Milliseconds 200
        }
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    if ($p.IsOpen) { $p.Close() }
}
