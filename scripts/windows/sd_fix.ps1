$ErrorActionPreference = 'Continue'
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\sd_fix.log'
"start" | Out-File -FilePath $log -Encoding utf8

Set-Service vds -StartupType Manual -ErrorAction SilentlyContinue
Start-Service vds -ErrorAction SilentlyContinue
"vds=$((Get-Service vds).Status)" | Out-File -FilePath $log -Append -Encoding utf8

Update-HostStorageCache
& diskpart /s 'C:\Users\akant\AppData\Local\Temp\opencode\sd_rescan.txt' 2>&1 | Out-File -FilePath $log -Append -Encoding utf8
Start-Sleep -Seconds 5

$p = Get-Partition -DiskNumber 2 | Where-Object { $_.PartitionNumber -eq 1 }
"part type=$($p.Type) letter=$($p.DriveLetter) mbrtype=$($p.MbrType)" | Out-File -FilePath $log -Append -Encoding utf8

try {
    $v = Format-Volume -Partition $p -FileSystem exFAT -NewFileSystemLabel 'RADXA' -Confirm:$false
    "OK $($v.DriveLetter) $($v.FileSystem) $($v.FileSystemLabel) $([math]::Round($v.Size/1GB,2))GB" | Out-File -FilePath $log -Append -Encoding utf8
    exit
} catch {
    "format fail: $($_.Exception.Message)" | Out-File -FilePath $log -Append -Encoding utf8
}

# re-enumerate the card reader device
$dev = Get-PnpDevice -Class DiskDrive | Where-Object { $_.FriendlyName -like '*SD*' -or $_.FriendlyName -like '*Generic*' }
foreach ($d in $dev) {
    "reenum $($d.InstanceId)" | Out-File -FilePath $log -Append -Encoding utf8
    Disable-PnpDevice -InstanceId $d.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 4
    Enable-PnpDevice -InstanceId $d.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 8
}
Update-HostStorageCache

try {
    $p = Get-Partition -DiskNumber 2 | Where-Object { $_.PartitionNumber -eq 1 }
    $v = Format-Volume -Partition $p -FileSystem exFAT -NewFileSystemLabel 'RADXA' -Confirm:$false
    "OK2 $($v.DriveLetter) $($v.FileSystem) $($v.FileSystemLabel) $([math]::Round($v.Size/1GB,2))GB" | Out-File -FilePath $log -Append -Encoding utf8
} catch {
    "format2 fail: $($_.Exception.Message)" | Out-File -FilePath $log -Append -Encoding utf8
}
