$log = 'C:\Users\akant\AppData\Local\Temp\opencode\assign_p2_log.txt'
Start-Transcript -Path $log -Force | Out-Null
Write-Host "=== Setting partition 2 drive letter ==="
Get-Partition -DiskNumber 2 -PartitionNumber 2 | Set-Partition -NewDriveLetter F
Write-Host "=== Result ==="
Get-Partition -DiskNumber 2
Stop-Transcript | Out-Null
