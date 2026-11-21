$log = 'C:\Users\akant\AppData\Local\Temp\opencode\verify_card2.log'
$n = 0
while ($n -lt 180) {
    if (Test-Path $log) {
        if (Select-String -Path $log -Pattern '=== DONE ===' -Quiet -ErrorAction SilentlyContinue) { break }
    }
    Start-Sleep -Seconds 2
    $n += 2
}
if (Test-Path $log) { Get-Content $log } else { Write-Host "NO LOG - UAC not accepted" }
