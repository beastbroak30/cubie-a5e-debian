$ErrorActionPreference = 'Continue'
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\sd_newvol.log'
"start $(Get-Date -Format o)" | Out-File -FilePath $log -Encoding utf8

# restart the reader device to force media re-read
$dev = Get-PnpDevice -Class DiskDrive -ErrorAction SilentlyContinue |
    Where-Object { $_.FriendlyName -like '*SD*' -or $_.FriendlyName -like '*Generic*' }
foreach ($d in $dev) {
    "cycle $($d.InstanceId) status=$($d.Status)" | Out-File -FilePath $log -Append -Encoding utf8
    Disable-PnpDevice -InstanceId $d.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
    Enable-PnpDevice -InstanceId $d.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 12
}
Update-HostStorageCache
Start-Sleep -Seconds 3

$dsk = Get-Disk -Number 2
"disk online=$($dsk.OperationalStatus) partitions=$($dsk.Partitions.Count)" | Out-File -FilePath $log -Append -Encoding utf8

try {
    $v = New-Volume -DiskNumber 2 -FileSystem exFAT -NewFileSystemLabel 'RADXA' -AssignDriveLetter -ErrorAction Stop
    "NEWVOL OK $($v.DriveLetter) $($v.FileSystem) $($v.FileSystemLabel) $([math]::Round($v.Size/1GB,2))GB" | Out-File -FilePath $log -Append -Encoding utf8
} catch {
    "New-Volume fail: $($_.Exception.Message)" | Out-File -FilePath $log -Append -Encoding utf8
}

Get-Partition -DiskNumber 2 -ErrorAction SilentlyContinue |
    Select-Object PartitionNumber,DriveLetter,@{n='SizeGB';e={[math]::Round($_.Size/1GB,2)}},Type |
    Format-Table -AutoSize | Out-File -FilePath $log -Append -Encoding utf8
Get-Volume | Where-Object { $_.DriveType -eq 'Removable' } |
    Format-List DriveLetter,FileSystemLabel,FileSystem,Size,SizeRemaining | Out-File -FilePath $log -Append -Encoding utf8
"done $(Get-Date -Format o)" | Out-File -FilePath $log -Append -Encoding utf8
