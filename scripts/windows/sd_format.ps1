$ErrorActionPreference = 'Stop'
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\sd_format.log'
try {
    Get-Partition -DiskNumber 2 -ErrorAction SilentlyContinue | ForEach-Object {
        Remove-Partition -DiskNumber 2 -PartitionNumber $_.PartitionNumber -Confirm:$false
    }
    Start-Sleep -Seconds 2
    $p = New-Partition -DiskNumber 2 -UseMaximumSize -AssignDriveLetter
    $v = $p | Format-Volume -FileSystem exFAT -NewFileSystemLabel 'SDCARD' -Confirm:$false
    "OK $($v.DriveLetter) $($v.FileSystem) $([math]::Round($v.Size/1GB,2))GB" | Out-File -FilePath $log -Encoding utf8
} catch {
    "FAIL $($_.Exception.Message)" | Out-File -FilePath $log -Encoding utf8
}
