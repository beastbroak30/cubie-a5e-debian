$p = Start-Process -FilePath "powershell.exe" `
    -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','C:\Users\akant\AppData\Local\Temp\opencode\run_write_p3_ncm.ps1' `
    -Verb RunAs -PassThru
Write-Host ("Elevated PID: " + $p.Id)
$p.WaitForExit()
Write-Host ("Exit code: " + $p.ExitCode)
