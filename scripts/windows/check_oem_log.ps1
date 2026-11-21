$log = 'C:\Users\akant\AppData\Local\Temp\opencode\bind_rndis.log'
$n = 0
while ($n -lt 15) {
    if (Test-Path $log) {
        if (Select-String -Path $log -Pattern 'Status' -Quiet -ErrorAction SilentlyContinue) { break }
        if (Select-String -Path $log -Pattern 'Exception' -Quiet -ErrorAction SilentlyContinue) { break }
    }
    Start-Sleep -Seconds 1
    $n += 1
}
if (Test-Path $log) { Get-Content $log } else { Write-Host "No log yet." }
