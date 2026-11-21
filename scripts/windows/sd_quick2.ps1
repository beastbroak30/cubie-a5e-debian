$ErrorActionPreference = 'Stop'
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\sd_quick.log'
try {
    Update-HostStorageCache
    $p = Get-Partition -DiskNumber 2 | Where-Object { $_.PartitionNumber -eq 1 }
    if (-not $p.DriveLetter) { $p = $p | Set-Partition -NewDriveLetter E }

    $ok = $false
    for ($i = 1; $i -le 15; $i++) {
        try {
            $v = Format-Volume -Partition $p -FileSystem exFAT -NewFileSystemLabel 'RADXA' -Confirm:$false
            "OK $($v.DriveLetter) $($v.FileSystem) $($v.FileSystemLabel) $([math]::Round($v.Size/1GB,2))GB attempt=$i" | Out-File -FilePath $log -Encoding utf8
            $ok = $true
            break
        } catch {
            "attempt $i : $($_.Exception.Message)" | Out-File -FilePath $log -Append -Encoding utf8
            Start-Sleep -Seconds 3
            Update-HostStorageCache
            $p = Get-Partition -DiskNumber 2 | Where-Object { $_.PartitionNumber -eq 1 }
        }
    }
    if (-not $ok) { "FAIL all attempts" | Out-File -FilePath $log -Append -Encoding utf8 }
} catch {
    "FAIL $($_.Exception.Message)" | Out-File -FilePath $log -Encoding utf8
}
