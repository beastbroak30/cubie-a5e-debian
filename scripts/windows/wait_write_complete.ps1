$log = 'C:\Users\akant\AppData\Local\Temp\opencode\write_p3_sd.log'
while ($true) {
    if (Test-Path $log) {
        $last = Get-Content $log -Tail 15
        if ($last -match 'Flashing finished' -or $last -match 'Exception') {
            $last
            break
        }
    }
    Start-Sleep -Seconds 5
}
