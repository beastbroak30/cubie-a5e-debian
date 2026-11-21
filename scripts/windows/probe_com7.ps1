$ErrorActionPreference = "Continue"

Write-Host "=== COM7 DEVICE INFO ==="
Get-PnpDevice -Class Ports -ErrorAction SilentlyContinue | Select-Object FriendlyName,InstanceId,Status | Format-Table -AutoSize

Write-Host "=== PROBING COM7 ==="
$p = New-Object System.IO.Ports.SerialPort('COM7', 115200, [System.IO.Ports.Parity]::None, 8, [System.IO.Ports.StopBits]::One)
$p.DtrEnable = $true
$p.RtsEnable = $true
$p.ReadTimeout = 1500
$p.WriteTimeout = 1000

try {
    $p.Open()
    Write-Host "Opened COM7 successfully."
    $b = $p.ReadExisting()
    if ($b) { Write-Host ("Initial buffer on COM7: '" + $b + "'") }
    
    Write-Host "Sending newline to COM7..."
    $p.Write("`r`n")
    Start-Sleep -Milliseconds 600
    $resp = $p.ReadExisting()
    Write-Host ("Response: '" + $resp + "'")
    
    Write-Host "Sending second newline..."
    $p.Write("`r`n")
    Start-Sleep -Milliseconds 800
    $resp2 = $p.ReadExisting()
    Write-Host ("Response 2: '" + $resp2 + "'")
} catch {
    Write-Host "COM7 Error: $($_.Exception.Message)"
} finally {
    if ($p.IsOpen) { $p.Close() }
}
