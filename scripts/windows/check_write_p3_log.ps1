$log = 'C:\Users\akant\AppData\Local\Temp\opencode\write_p3_sd.log'
$n = 0
while ($n -lt 60) {
    if (Test-Path $log) {
        if (Select-String -Path $log -Pattern 'Flashing finished' -Quiet -ErrorAction SilentlyContinue) { break }
        if (Select-String -Path $log -Pattern 'Exception' -Quiet -ErrorAction SilentlyContinue) { break }
    }
    Start-Sleep -Seconds 2
    $n += 1
}
if (Test-Path $log) { Get-Content $log } else { Write-Host "No log yet." }
