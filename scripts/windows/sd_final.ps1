$ErrorActionPreference = 'Continue'
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\sd_final.log'
"start $(Get-Date -Format o)" | Out-File -FilePath $log -Encoding utf8

# 1. wipe partitions on disk 2
Get-Partition -DiskNumber 2 -ErrorAction SilentlyContinue | ForEach-Object {
    Remove-Partition -DiskNumber 2 -PartitionNumber $_.PartitionNumber -Confirm:$false -ErrorAction SilentlyContinue
}
Clear-Disk -Number 2 -RemoveData -RemoveOEM -Confirm:$false -ErrorAction SilentlyContinue
"cleaned" | Out-File -FilePath $log -Append -Encoding utf8

# 2. power-cycle the card reader
$dev = Get-PnpDevice -Class DiskDrive -ErrorAction SilentlyContinue | Where-Object { $_.FriendlyName -like '*SD*' -or $_.FriendlyName -like '*Generic*' }
foreach ($d in $dev) {
    "cycle $($d.InstanceId)" | Out-File -FilePath $log -Append -Encoding utf8
    Disable-PnpDevice -InstanceId $d.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
    Enable-PnpDevice -InstanceId $d.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 10
}
Update-HostStorageCache
Start-Sleep -Seconds 3

# 3. create + format in one diskpart pass
$dp = 'C:\Users\akant\AppData\Local\Temp\opencode\sd_dp_final.txt'
@(
    'select disk 2'
    'clean'
    'create partition primary'
    'format fs=exfat quick label=RADXA'
    'assign'
    'list partition'
    'list volume'
    'exit'
) | Set-Content -Path $dp -Encoding ascii
& diskpart /s $dp 2>&1 | Out-File -FilePath $log -Append -Encoding utf8

Get-Volume | Where-Object { $_.DriveType -eq 'Removable' } |
    Select-Object DriveLetter, FileSystemLabel, FileSystem, Size, SizeRemaining |
    Format-List | Out-File -FilePath $log -Append -Encoding utf8
"done $(Get-Date -Format o)" | Out-File -FilePath $log -Append -Encoding utf8
