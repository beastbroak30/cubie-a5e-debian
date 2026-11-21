$ErrorActionPreference = 'Continue'
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\sd_mount.log'
"start" | Out-File -FilePath $log -Encoding utf8

Restart-Service vds -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3
Update-HostStorageCache
Start-Sleep -Seconds 2

$dp = 'C:\Users\akant\AppData\Local\Temp\opencode\dp_mount.txt'
@('select disk 2','list volume','select partition 1','detail partition','exit') |
    Set-Content -Path $dp -Encoding ascii
& diskpart /s $dp 2>&1 | Out-File -FilePath $log -Append -Encoding utf8

$p = Get-Partition -DiskNumber 2 | Where-Object { $_.PartitionNumber -eq 1 }
"letter=$($p.DriveLetter) type=$($p.Type)" | Out-File -FilePath $log -Append -Encoding utf8

try {
    $v = Get-Partition -DiskNumber 2 | Get-Volume -ErrorAction Stop
    "volume object: $($v.DriveLetter) $($v.FileSystem) $($v.FileSystemLabel) $($v.Size)" | Out-File -FilePath $log -Append -Encoding utf8
} catch {
    "getvolume fail: $($_.Exception.Message)" | Out-File -FilePath $log -Append -Encoding utf8
}

# try to open the raw partition through its volume GUID-less path
$paths = @('\\.\E:', '\\.\PhysicalDrive2')
foreach ($pth in $paths) {
    try {
        $fs = New-Object System.IO.FileStream($pth, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        $fs.Dispose()
        "open ok: $pth" | Out-File -FilePath $log -Append -Encoding utf8
    } catch {
        "open fail: $pth $($_.Exception.Message)" | Out-File -FilePath $log -Append -Encoding utf8
    }
}
"done" | Out-File -FilePath $log -Append -Encoding utf8
