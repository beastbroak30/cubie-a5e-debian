$ErrorActionPreference = 'Stop'
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\sd_quick.log'
try {
    # kill the running full-format job
    Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" |
        Where-Object { $_.CommandLine -like '*sd_fullformat.ps1*' } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
    Start-Sleep -Seconds 3

    Get-Partition -DiskNumber 2 -ErrorAction SilentlyContinue | ForEach-Object {
        Remove-Partition -DiskNumber 2 -PartitionNumber $_.PartitionNumber -Confirm:$false
    }
    Clear-Disk -Number 2 -RemoveData -RemoveOEM -Confirm:$false
    Start-Sleep -Seconds 2

    $d = Get-Disk -Number 2
    if ($d.PartitionStyle -eq 'RAW') { Initialize-Disk -Number 2 -PartitionStyle MBR }
    if ($d.IsReadOnly) { Set-Disk -Number 2 -IsReadOnly $false }

    $p = New-Partition -DiskNumber 2 -UseMaximumSize -AssignDriveLetter
    $v = $p | Format-Volume -FileSystem exFAT -NewFileSystemLabel 'RADXA' -Confirm:$false
    "OK $($v.DriveLetter) $($v.FileSystem) $($v.FileSystemLabel) $([math]::Round($v.Size/1GB,2))GB" | Out-File -FilePath $log -Encoding utf8
} catch {
    "FAIL $($_.Exception.Message)" | Out-File -FilePath $log -Encoding utf8
}
