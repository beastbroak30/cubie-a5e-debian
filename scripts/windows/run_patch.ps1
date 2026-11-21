$log = 'C:\Users\akant\AppData\Local\Temp\opencode\patch_sd_card.log'
Remove-Item $log -Force -ErrorAction SilentlyContinue

Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','C:\Users\akant\AppData\Local\Temp\opencode\patch_sd_card.ps1'

$n = 0
while ($n -lt 60) {
    if (Test-Path $log) {
        if (Select-String -Path $log -Pattern '=== FINISHED' -Quiet -ErrorAction SilentlyContinue) { break }
        if (Select-String -Path $log -Pattern 'ABORT|Error' -Quiet -ErrorAction SilentlyContinue) { break }
    }
    Start-Sleep -Seconds 1
    $n += 1
}

if (Test-Path $log) {
    Get-Content $log
} else {
    Write-Host "UAC prompt pending or denied."
}
