$log = 'C:\Users\akant\AppData\Local\Temp\opencode\serial.log'
$n = 0
$target = 500
while ($n -lt 180) {
    if (Test-Path $log) {
        $len = (Get-Item $log).Length
        if ($len -gt $target) { break }
    }
    Start-Sleep -Seconds 2
    $n += 2
}
if (-not (Test-Path $log)) { Write-Host "NO LOG FILE — capture did not start"; exit }
$len = (Get-Item $log).Length
Write-Host "=== log size: $len bytes, waited $n s ==="
Get-Content $log -Raw -Encoding UTF8
