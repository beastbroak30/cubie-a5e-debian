$ErrorActionPreference = "Stop"

# ---- self-elevate ----
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Not elevated. Relaunching with UAC prompt..."
    Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',$PSCommandPath
    exit 0
}

$log = "C:\Users\akant\AppData\Local\Temp\opencode\flash2.log"
try { Start-Transcript -Path $log -Force | Out-Null } catch {}

$img    = "D:\misc_prj\radxa_firmware\cubie-a5e-lite-arm64.img"
$diskNo = 2
$raw    = "\\.\PhysicalDrive$diskNo"

Write-Host "=== FLASH START $(Get-Date -Format o) ==="
Get-Disk -Number $diskNo | Select-Object Number,FriendlyName,Size,PartitionStyle,IsReadOnly,IsOffline | Format-List

if (-not (Test-Path $img)) { Write-Host "ERROR image missing: $img"; Stop-Transcript; Read-Host "Enter to close"; exit 1 }
$imgLen = (Get-Item $img).Length
Write-Host "Image: $img  bytes=$imgLen"

# make writable
try { Set-Disk -Number $diskNo -IsReadOnly $false -ErrorAction Stop; Write-Host "IsReadOnly=false OK" } catch { Write-Host "Set-Disk readonly: $_" }
try { Set-Disk -Number $diskNo -IsOffline $false -ErrorAction Stop; Write-Host "IsOffline=false OK" } catch { Write-Host "Set-Disk offline: $_" }

# clear existing signature so no volume is mounted
$dp = "C:\Users\akant\AppData\Local\Temp\opencode\dp_clean.txt"
@("select disk $diskNo","clean","rescan") | Set-Content -Path $dp -Encoding ASCII
Write-Host "Running diskpart clean on disk $diskNo ..."
& diskpart.exe /s $dp
Write-Host "diskpart exit=$LASTEXITCODE"
Get-Disk -Number $diskNo | Select-Object Number,PartitionStyle,Size | Format-List

# raw write with WriteThrough
Write-Host "Opening $raw for raw write..."
$fsIn  = [System.IO.File]::Open($img, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
$fsOut = New-Object System.IO.FileStream($raw, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Write, [System.IO.FileShare]::ReadWrite, 1MB, [System.IO.FileOptions]::WriteThrough)

$buf = New-Object byte[] (4MB)
[long]$done = 0
$sw = [System.Diagnostics.Stopwatch]::StartNew()
try {
    while (($n = $fsIn.Read($buf, 0, $buf.Length)) -gt 0) {
        $fsOut.Write($buf, 0, $n)
        $done += $n
        if (($done % (256MB)) -eq 0 -or $done -eq $imgLen) {
            $pct = [math]::Round($done * 100.0 / $imgLen, 1)
            $mb  = [math]::Round($done / 1MB)
            $spd = [math]::Round(($done / 1MB) / [math]::Max($sw.Elapsed.TotalSeconds, 0.001), 1)
            Write-Host ("PROGRESS {0}%  {1} MB / 4096 MB  {2} MB/s" -f $pct, $mb, $spd)
        }
    }
    $fsOut.Flush()
} finally {
    $fsOut.Dispose()
    $fsIn.Dispose()
}
$sw.Stop()
Write-Host "WROTE $done bytes in $([math]::Round($sw.Elapsed.TotalSeconds,1)) s"

Start-Sleep -Seconds 2
Update-Disk -Number $diskNo -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

Write-Host "=== PARTITIONS AFTER FLASH ==="
Get-Disk -Number $diskNo | Select-Object Number,PartitionStyle,Size | Format-List
Get-Partition -DiskNumber $diskNo -ErrorAction SilentlyContinue | Select-Object PartitionNumber,Offset,Size,Type,DriveLetter | Format-Table -AutoSize

# verify signatures in first 32 MB
$fsV = New-Object System.IO.FileStream($raw, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite, 1MB)
try {
    $head = New-Object byte[] (32MB)
    $r = $fsV.Read($head, 0, $head.Length)
    $s256 = [System.Text.Encoding]::ASCII.GetString($head, 256*512, 8)
    $s24576 = [System.Text.Encoding]::ASCII.GetString($head, 24576*512, 13)
    $sig = [System.Text.Encoding]::ASCII.GetString($head, 512, 8)
    Write-Host "sector256 magic : '$s256'   (expect eGON.BT0)"
    Write-Host "sector24576 magic: '$s24576' (expect sunxi-package)"
    Write-Host "LBA1 signature  : '$sig'    (expect EFI PART)"
} finally { $fsV.Dispose() }

Write-Host "=== FLASH DONE $(Get-Date -Format o) ==="
Stop-Transcript | Out-Null
Write-Host ""
Read-Host "Press Enter to close"
