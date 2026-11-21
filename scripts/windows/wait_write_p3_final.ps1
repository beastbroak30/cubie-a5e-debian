$log = 'C:\Users\akant\AppData\Local\Temp\opencode\write_p3_final.log'
while ($true) {
    if (Test-Path $log) {
        $last = Get-Content $log -Tail 10
        if ($last -match 'Flashing finished' -or $last -match 'Exception') {
            $last
            break
        }
    }
    Start-Sleep -Seconds 5
}
