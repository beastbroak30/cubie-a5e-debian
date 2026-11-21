$ErrorActionPreference = 'Continue'
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\sd_verify.log'
$prefix = 'C:\Users\akant\AppData\Local\Temp\opencode\card_prefix.bin'
"start $(Get-Date -Format o)" | Out-File -FilePath $log -Encoding utf8

# 1. read the card back and hash it
$len = 67108864
$buf = New-Object byte[] $len
$fs = New-Object System.IO.FileStream('\\.\PhysicalDrive2', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
try {
    $fs.Position = 0
    $total = 0
    while ($total -lt $len) {
        $n = $fs.Read($buf, $total, [Math]::Min(1MB, $len - $total))
        if ($n -le 0) { break }
        $total += $n
    }
    "read back $total bytes" | Out-File -FilePath $log -Append -Encoding utf8
} finally { $fs.Dispose() }

$md5 = [System.Security.Cryptography.MD5]::Create()
$hashCard = ([BitConverter]::ToString($md5.ComputeHash($buf)) -replace '-', '').ToLower()
$hashFile = (Get-FileHash -Path $prefix -Algorithm MD5).Hash.ToLower()
"card = $hashCard" | Out-File -FilePath $log -Append -Encoding utf8
"file = $hashFile" | Out-File -FilePath $log -Append -Encoding utf8
"match = $($hashCard -eq $hashFile)" | Out-File -FilePath $log -Append -Encoding utf8

# 2. deeper device restart
$dev = Get-PnpDevice -Class DiskDrive -ErrorAction SilentlyContinue |
    Where-Object { $_.FriendlyName -like '*SD*' -or $_.FriendlyName -like '*Generic*' }
foreach ($d in $dev) {
    "restart $($d.InstanceId)" | Out-File -FilePath $log -Append -Encoding utf8
    & pnputil /restart-device "$($d.InstanceId)" 2>&1 | Out-File -FilePath $log -Append -Encoding utf8
}
Start-Sleep -Seconds 15
Update-HostStorageCache
Start-Sleep -Seconds 5

"--- volumes ---" | Out-File -FilePath $log -Append -Encoding utf8
Get-Partition -DiskNumber 2 -ErrorAction SilentlyContinue |
    Select-Object PartitionNumber,DriveLetter,Type | Format-Table -AutoSize |
    Out-File -FilePath $log -Append -Encoding utf8
Get-Partition -DiskNumber 2 -ErrorAction SilentlyContinue | Get-Volume -ErrorAction SilentlyContinue |
    Format-List DriveLetter,FileSystemLabel,FileSystem,Size | Out-File -FilePath $log -Append -Encoding utf8
Get-Volume | Where-Object { $_.DriveType -eq 'Removable' } |
    Format-List DriveLetter,FileSystemLabel,FileSystem,Size | Out-File -FilePath $log -Append -Encoding utf8
"done $(Get-Date -Format o)" | Out-File -FilePath $log -Append -Encoding utf8
