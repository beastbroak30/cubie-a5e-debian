$ErrorActionPreference = 'Continue'
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\sd_gpt.log'
"start" | Out-File -FilePath $log -Encoding utf8

Get-Partition -DiskNumber 2 -ErrorAction SilentlyContinue | ForEach-Object {
    Remove-Partition -DiskNumber 2 -PartitionNumber $_.PartitionNumber -Confirm:$false -ErrorAction SilentlyContinue
}
Clear-Disk -Number 2 -RemoveData -RemoveOEM -Confirm:$false -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Update-HostStorageCache

try {
    Initialize-Disk -Number 2 -PartitionStyle GPT -ErrorAction Stop
    "init gpt ok" | Out-File -FilePath $log -Append -Encoding utf8
} catch {
    "init: $($_.Exception.Message)" | Out-File -FilePath $log -Append -Encoding utf8
}
Start-Sleep -Seconds 2

try {
    $p = New-Partition -DiskNumber 2 -UseMaximumSize -AssignDriveLetter -ErrorAction Stop
    "newpart $($p.DriveLetter) $($p.Type)" | Out-File -FilePath $log -Append -Encoding utf8
    Start-Sleep -Seconds 6
    Update-HostStorageCache
    $vols = Get-Volume | Where-Object { $_.DriveLetter -eq $p.DriveLetter }
    "volcount=$(@($vols).Count)" | Out-File -FilePath $log -Append -Encoding utf8
    $v = Format-Volume -Partition $p -FileSystem exFAT -NewFileSystemLabel 'RADXA' -Confirm:$false -ErrorAction Stop
    "OK $($v.DriveLetter) $($v.FileSystem) $($v.FileSystemLabel) $([math]::Round($v.Size/1GB,2))GB" | Out-File -FilePath $log -Append -Encoding utf8
} catch {
    "fail: $($_.Exception.Message)" | Out-File -FilePath $log -Append -Encoding utf8
}
Get-Disk -Number 2 | Format-List Number,PartitionStyle,Size,HealthStatus | Out-File -FilePath $log -Append -Encoding utf8
