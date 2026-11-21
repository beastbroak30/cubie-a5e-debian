$ErrorActionPreference = 'Continue'
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\sd_zap.log'
"start $(Get-Date -Format o)" | Out-File -FilePath $log -Encoding utf8

# --- raw write with verified byte counts ---
$PATH = '\\.\PhysicalDrive2'
function Do-Write([int64]$offset, [byte[]]$buf) {
    $fs = New-Object System.IO.FileStream($PATH, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::ReadWrite)
    try { $fs.Position = $offset; $fs.Write($buf, 0, $buf.Length); $fs.Flush($true) } finally { $fs.Dispose() }
}
function Do-Read([int64]$offset, [int]$len) {
    $fs = New-Object System.IO.FileStream($PATH, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    try { $fs.Position = $offset; $buf = New-Object byte[] $len; $n = $fs.Read($buf, 0, $len); return @{ Buf = $buf; N = $n } } finally { $fs.Dispose() }
}

# zero the first 1 MiB (MBR + alignment area)
$zero = New-Object byte[] (1MB)
Do-Write 0 $zero
"zeroed first 1MiB" | Out-File -FilePath $log -Append -Encoding utf8

# verify persistence with correct byte counting
$test = New-Object byte[] 4096
for ($i = 0; $i -lt 4096; $i++) { $test[$i] = 0x5A }
Do-Write 1048576 $test
$r = Do-Read 1048576 4096
$mism = 0
for ($i = 0; $i -lt [Math]::Min($r.N, 4096); $i++) { if ($r.Buf[$i] -ne 0x5A) { $mism++ } }
"raw test: read=$($r.N) mismatch=$mism" | Out-File -FilePath $log -Append -Encoding utf8

# verify MBR area is now zeros
$r0 = Do-Read 0 512
$nz = 0
for ($i = 0; $i -lt $r0.N; $i++) { if ($r0.Buf[$i] -ne 0) { $nz++ } }
"mbr sector nonzero bytes=$nz read=$($r0.N)" | Out-File -FilePath $log -Append -Encoding utf8

# --- let Windows rebuild the disk ---
$dev = Get-PnpDevice -Class DiskDrive -ErrorAction SilentlyContinue |
    Where-Object { $_.FriendlyName -like '*SD*' -or $_.FriendlyName -like '*Generic*' }
foreach ($d in $dev) {
    Disable-PnpDevice -InstanceId $d.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
    Enable-PnpDevice -InstanceId $d.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 12
}
Update-HostStorageCache

$dp = 'C:\Users\akant\AppData\Local\Temp\opencode\sd_dp_zap.txt'
@(
    'select disk 2'
    'clean'
    'create partition primary'
    'list volume'
    'exit'
) | Set-Content -Path $dp -Encoding ascii
& diskpart /s $dp 2>&1 | Out-File -FilePath $log -Append -Encoding utf8

# format if a volume now exists
$p = Get-Partition -DiskNumber 2 -ErrorAction SilentlyContinue | Where-Object { $_.PartitionNumber -eq 1 }
try {
    $v = Format-Volume -Partition $p -FileSystem exFAT -NewFileSystemLabel 'RADXA' -Confirm:$false -ErrorAction Stop
    "FORMAT OK $($v.DriveLetter) $($v.FileSystem) $($v.FileSystemLabel) $([math]::Round($v.Size/1GB,2))GB" | Out-File -FilePath $log -Append -Encoding utf8
} catch {
    "FORMAT FAIL $($_.Exception.Message)" | Out-File -FilePath $log -Append -Encoding utf8
}
"done $(Get-Date -Format o)" | Out-File -FilePath $log -Append -Encoding utf8
