$ErrorActionPreference = 'Continue'
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\sd_free.log'
"start" | Out-File -FilePath $log -Encoding utf8
Get-Partition -DiskNumber 2 -ErrorAction SilentlyContinue | ForEach-Object {
    Remove-Partition -DiskNumber 2 -PartitionNumber $_.PartitionNumber -Confirm:$false -ErrorAction SilentlyContinue
}
Clear-Disk -Number 2 -RemoveData -RemoveOEM -Confirm:$false -ErrorAction SilentlyContinue
"partitions: $((Get-Partition -DiskNumber 2 -ErrorAction SilentlyContinue | Measure-Object).Count)" | Out-File -FilePath $log -Append -Encoding utf8
mountvol /R 2>&1 | Out-File -FilePath $log -Append -Encoding utf8
Start-Sleep -Seconds 3
"done" | Out-File -FilePath $log -Append -Encoding utf8
