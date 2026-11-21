$ErrorActionPreference = 'Stop'
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\sd_fullformat.log'
try {
    "start $(Get-Date -Format o)" | Out-File -FilePath $log -Encoding utf8

    # remove every partition on disk 2
    Get-Partition -DiskNumber 2 -ErrorAction SilentlyContinue | ForEach-Object {
        Remove-Partition -DiskNumber 2 -PartitionNumber $_.PartitionNumber -Confirm:$false
    }
    Clear-Disk -Number 2 -RemoveData -RemoveOEM -Confirm:$false
    Start-Sleep -Seconds 2

    $d = Get-Disk -Number 2
    if ($d.PartitionStyle -eq 'RAW') { Initialize-Disk -Number 2 -PartitionStyle MBR }
    if ($d.IsReadOnly) { Set-Disk -Number 2 -IsReadOnly $false }

    $p = New-Partition -DiskNumber 2 -UseMaximumSize -AssignDriveLetter
    "partition $($p.DriveLetter) $([math]::Round($p.Size/1GB,2))GB" | Out-File -FilePath $log -Append -Encoding utf8

    # full (slow) format: writes filesystem across whole volume
    $v = $p | Format-Volume -FileSystem exFAT -NewFileSystemLabel 'SDCARD' -Full -Confirm:$false
    "OK $($v.DriveLetter) $($v.FileSystem) $($v.FileSystemLabel) $([math]::Round($v.Size/1GB,2))GB" | Out-File -FilePath $log -Append -Encoding utf8
    "done $(Get-Date -Format o)" | Out-File -FilePath $log -Append -Encoding utf8
} catch {
    "FAIL $($_.Exception.Message)" | Out-File -FilePath $log -Append -Encoding utf8
}
