$log = 'C:\Users\akant\AppData\Local\Temp\opencode\attach_sd.log'
$n = 0
while ($n -lt 30) {
    if (Test-Path $log) {
        if (Select-String -Path $log -Pattern 'BUSID' -Quiet -ErrorAction SilentlyContinue) { break }
    }
    Start-Sleep -Seconds 1
    $n += 1
}
if (Test-Path $log) { Get-Content $log } else { Write-Host "No log yet." }
