$log = 'C:\Users\akant\AppData\Local\Temp\opencode\serial.log'
$prev = -1
$n = 0
while ($n -lt 60) {
    $len = (Get-Item $log).Length
    if ($len -ne $prev -and $len -gt 0) { $prev = $len; $n = 0 } else { $n += 2 }
    Start-Sleep -Seconds 2
}
$len = (Get-Item $log).Length
Write-Host ("=== log size: " + $len + " bytes ===")
Get-Content $log -Raw
