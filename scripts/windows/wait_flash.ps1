$log = 'C:\Users\akant\AppData\Local\Temp\opencode\flash2.log'
$n = 0
while ($n -lt 900) {
    if (Test-Path $log) {
        if (Select-String -Path $log -Pattern 'FLASH DONE' -Quiet -ErrorAction SilentlyContinue) { break }
    }
    Start-Sleep -Seconds 2
    $n += 2
}
if (Test-Path $log) { Get-Content $log } else { Write-Host "NO LOG FILE - elevated script never ran" }
