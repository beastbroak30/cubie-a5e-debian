$log = 'C:\Users\akant\AppData\Local\Temp\opencode\assign_p2_log.txt'
$n = 0
while ($n -lt 15) {
    if (Test-Path $log) {
        if (Select-String -Path $log -Pattern 'Result' -Quiet -ErrorAction SilentlyContinue) { break }
    }
    Start-Sleep -Seconds 1
    $n += 1
}
if (Test-Path $log) { Get-Content $log } else { Write-Host "No log yet." }
