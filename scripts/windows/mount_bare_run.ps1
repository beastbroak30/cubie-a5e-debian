$log = 'C:\Users\akant\AppData\Local\Temp\opencode\mount_bare.log'
Start-Transcript -Path $log -Force | Out-Null
Write-Host "=== WSL MOUNT PHYSICALDRIVE2 ==="
wsl --mount \\.\PHYSICALDRIVE2 --bare
Write-Host ("Exit code: " + $LASTEXITCODE)
wsl -u root -- lsblk
Stop-Transcript | Out-Null
