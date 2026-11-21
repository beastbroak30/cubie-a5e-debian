$ErrorActionPreference = "Continue"
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "elevating..."
    Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',$PSCommandPath
    exit 0
}
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\verify_card2.log'
Start-Transcript -Path $log -Force | Out-Null

Write-Host "=== RESCAN ==="
Update-Disk -Number 2 -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Get-Disk -Number 2 | Select-Object Number,FriendlyName,Size,PartitionStyle | Format-List
Write-Host "=== PARTITIONS ==="
Get-Partition -DiskNumber 2 -ErrorAction SilentlyContinue | Select-Object PartitionNumber,DriveLetter,Offset,Size,Type,GptType | Format-Table -AutoSize

Write-Host "=== RAW SNIFF ==="
$fs = New-Object System.IO.FileStream('\\.\PhysicalDrive2',[System.IO.FileMode]::Open,[System.IO.FileAccess]::Read,[System.IO.FileShare]::ReadWrite,1MB)
try {
    $len = 24576*512 + 512
    $buf = New-Object byte[] $len
    $read = 0
    while ($read -lt $len) {
        $n = $fs.Read($buf, $read, $len - $read)
        if ($n -le 0) { break }
        $read += $n
    }
    $lba1 = [System.Text.Encoding]::ASCII.GetString($buf, 512, 8)
    $bt0  = [System.Text.Encoding]::ASCII.GetString($buf, 256*512, 8)
    $toc  = [System.Text.Encoding]::ASCII.GetString($buf, 24576*512, 13)
    Write-Host ("LBA1    : '{0}'  expect 'EFI PART'" -f $lba1)
    Write-Host ("LBA256  : '{0}'  expect 'eGON.BT0'" -f ($bt0 -replace '[^\x20-\x7e]','.'))
    Write-Host ("LBA24576: '{0}'  expect 'sunxi-package'" -f $toc)
    Write-Host "read: $read bytes"
} finally { $fs.Dispose() }

Write-Host "=== EXT4 SIG IN P3 (offset 348127232 + 1080 = magic 0x53EF) ==="
$fs2 = New-Object System.IO.FileStream('\\.\PhysicalDrive2',[System.IO.FileMode]::Open,[System.IO.FileAccess]::Read,[System.IO.FileShare]::ReadWrite,1MB)
try {
    $fs2.Seek(348127232 + 1024 + 56, 'Begin') | Out-Null
    $m = New-Object byte[] 2
    $fs2.Read($m,0,2) | Out-Null
    Write-Host ("ext4 magic bytes: {0:X2} {1:X2} (expect 53 EF)" -f $m[0], $m[1])
} finally { $fs2.Dispose() }

Write-Host "=== DONE ==="
Stop-Transcript | Out-Null
Start-Sleep -Seconds 1
