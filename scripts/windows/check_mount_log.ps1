$log = 'C:\Users\akant\AppData\Local\Temp\opencode\mount_bare.log'
$n = 0
while ($n -lt 20) {
    if (Test-Path $log) {
        if (Select-String -Path $log -Pattern 'Exit code' -Quiet -ErrorAction SilentlyContinue) { break }
    }
    Start-Sleep -Seconds 1
    $n += 1
}
if (Test-Path $log) { Get-Content $log } else { Write-Host "No log yet." }
