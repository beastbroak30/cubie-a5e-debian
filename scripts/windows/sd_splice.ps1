$ErrorActionPreference = 'Continue'
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\sd_splice.log'
$prefix = 'C:\Users\akant\AppData\Local\Temp\opencode\card_prefix.bin'
"start $(Get-Date -Format o)" | Out-File -FilePath $log -Encoding utf8

$bytes = [System.IO.File]::ReadAllBytes($prefix)
"prefix bytes=$($bytes.Length)" | Out-File -FilePath $log -Append -Encoding utf8

try {
    $fs = New-Object System.IO.FileStream('\\.\PhysicalDrive2', [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::ReadWrite)
    try {
        $fs.Position = 0
        $fs.Write($bytes, 0, $bytes.Length)
        $fs.Flush($true)
    } finally { $fs.Dispose() }
    "spliced OK" | Out-File -FilePath $log -Append -Encoding utf8
} catch {
    "splice FAIL $($_.Exception.Message)" | Out-File -FilePath $log -Append -Encoding utf8
}

# re-enumerate so Windows re-reads the partition table
$dev = Get-PnpDevice -Class DiskDrive -ErrorAction SilentlyContinue |
    Where-Object { $_.FriendlyName -like '*SD*' -or $_.FriendlyName -like '*Generic*' }
foreach ($d in $dev) {
    Disable-PnpDevice -InstanceId $d.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
    Enable-PnpDevice -InstanceId $d.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 12
}
Update-HostStorageCache
Start-Sleep -Seconds 3

"--- disk ---" | Out-File -FilePath $log -Append -Encoding utf8
Get-Disk -Number 2 | Format-List Number,PartitionStyle,Size,OperationalStatus | Out-File -FilePath $log -Append -Encoding utf8
"--- partitions ---" | Out-File -FilePath $log -Append -Encoding utf8
Get-Partition -DiskNumber 2 -ErrorAction SilentlyContinue |
    Select-Object PartitionNumber,DriveLetter,@{n='SizeGB';e={[math]::Round($_.Size/1GB,2)}},Type |
    Format-Table -AutoSize | Out-File -FilePath $log -Append -Encoding utf8
"--- volumes ---" | Out-File -FilePath $log -Append -Encoding utf8
Get-Volume | Where-Object { $_.DriveType -eq 'Removable' } |
    Format-List DriveLetter,FileSystemLabel,FileSystem,Size,SizeRemaining,HealthStatus |
    Out-File -FilePath $log -Append -Encoding utf8
"done $(Get-Date -Format o)" | Out-File -FilePath $log -Append -Encoding utf8
