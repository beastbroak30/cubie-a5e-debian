$ErrorActionPreference = 'Continue'
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\sd_raw.log'
"start $(Get-Date -Format o)" | Out-File -FilePath $log -Encoding utf8

function Read-Raw([int]$offset, [int]$len) {
    $fs = New-Object System.IO.FileStream('\\.\PhysicalDrive2', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    try {
        $fs.Position = $offset
        $buf = New-Object byte[] $len
        $n = $fs.Read($buf, 0, $len)
        "read $n bytes @ $offset" | Out-File -FilePath $log -Append -Encoding utf8
        return $buf
    } finally { $fs.Dispose() }
}

# 1. read current MBR
$mbr1 = Read-Raw 0 512
"mbr1 hex: $(($mbr1[0..15] | ForEach-Object { $_.ToString('X2') }) -join ' ')" | Out-File -FilePath $log -Append -Encoding utf8

# 2. write a test pattern into the last 512 bytes of the disk (sector 0 is left intact except MBR)
$disk = Get-Disk -Number 2
$lastSector = [int64]([math]::Floor($disk.Size / 512)) - 1
$offset = $lastSector * 512
$pattern = New-Object byte[] 512
for ($i = 0; $i -lt 512; $i++) { $pattern[$i] = 0x5A }

$fs = New-Object System.IO.FileStream('\\.\PhysicalDrive2', [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::ReadWrite)
try {
    $fs.Position = $offset
    $fs.Write($pattern, 0, 512)
    $fs.Flush($true)
    "wrote 512 bytes @ $offset" | Out-File -FilePath $log -Append -Encoding utf8
} catch {
    "write error: $($_.Exception.Message)" | Out-File -FilePath $log -Append -Encoding utf8
} finally { $fs.Dispose() }

Start-Sleep -Seconds 2

# 3. read back
$back = Read-Raw $offset 512
$first = ($back[0..7] | ForEach-Object { $_.ToString('X2') }) -join ' '
"readback first8: $first" | Out-File -FilePath $log -Append -Encoding utf8
$ok = $true
for ($i = 0; $i -lt 512; $i++) { if ($back[$i] -ne 0x5A) { $ok = $false; break } }
"persist=$ok" | Out-File -FilePath $log -Append -Encoding utf8

# 4. force re-enumeration, then read again
$dev = Get-PnpDevice -Class DiskDrive -ErrorAction SilentlyContinue |
    Where-Object { $_.FriendlyName -like '*SD*' -or $_.FriendlyName -like '*Generic*' }
foreach ($d in $dev) {
    Disable-PnpDevice -InstanceId $d.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
    Enable-PnpDevice -InstanceId $d.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 10
}
Update-HostStorageCache
Start-Sleep -Seconds 3

$back2 = Read-Raw $offset 512
$ok2 = $true
for ($i = 0; $i -lt 512; $i++) { if ($back2[$i] -ne 0x5A) { $ok2 = $false; break } }
"persist_after_reenum=$ok2" | Out-File -FilePath $log -Append -Encoding utf8
"done $(Get-Date -Format o)" | Out-File -FilePath $log -Append -Encoding utf8
