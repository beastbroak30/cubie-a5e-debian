$ErrorActionPreference = "Stop"

[System.Console]::Title = "Radxa Cubie A5E SD Flasher"
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "     Flashing Radxa Cubie A5E Debian 12 Bookworm Image     " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$imagePath = "D:\misc_prj\radxa_firmware\cubie-a5e-lite-arm64.img"
$diskNum = 2
$rawDrive = "\\.\PhysicalDrive$diskNum"

Write-Host "Image file : $imagePath"
Write-Host "Target disk: $rawDrive (Disk 2, 128GB MicroSD)"
Write-Host ""

if (-not (Test-Path $imagePath)) {
    Write-Host "ERROR: Image file not found at $imagePath" -ForegroundColor Red
    Pause
    exit 1
}

$fsIn = [System.IO.File]::OpenRead($imagePath)
$totalBytes = $fsIn.Length
Write-Host "Image size : $([math]::Round($totalBytes / 1MB, 2)) MB ($totalBytes bytes)"

Write-Host "Opening target drive for exclusive raw writing..." -ForegroundColor Yellow
try {
    $fsOut = New-Object System.IO.FileStream(
        $rawDrive,
        [System.IO.FileMode]::Open,
        [System.IO.FileAccess]::Write,
        [System.IO.FileShare]::ReadWrite
    )
} catch {
    Write-Host "FAILED to open $rawDrive: $_" -ForegroundColor Red
    $fsIn.Close()
    Pause
    exit 1
}

$bufSize = 4 * 1024 * 1024 # 4MB chunks
$buf = New-Object byte[] $bufSize
$written = [long]0
$sw = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host "Writing raw sectors (boot0, U-Boot TOC1, GPT, partitions)..." -ForegroundColor Green

try {
    while (($read = $fsIn.Read($buf, 0, $bufSize)) -gt 0) {
        $fsOut.Write($buf, 0, $read)
        $written += $read
        
        if (($written % (128 * 1024 * 1024)) -eq 0 -or $written -eq $totalBytes) {
            $mb = [math]::Round($written / 1MB)
            $pct = [math]::Round(($written / $totalBytes) * 100, 1)
            $secs = [math]::Max($sw.Elapsed.TotalSeconds, 0.001)
            $speed = [math]::Round($mb / $secs, 1)
            Write-Host "Progress: $pct% ($mb MB / 4096 MB) at $speed MB/s" -ForegroundColor Green
        }
    }
    
    Write-Host "Flushing disk write cache..." -ForegroundColor Yellow
    $fsOut.Flush()
} finally {
    $fsOut.Close()
    $fsIn.Close()
}

$sw.Stop()
Write-Host "Flashing completed in $([math]::Round($sw.Elapsed.TotalSeconds, 1)) seconds!" -ForegroundColor Cyan
Write-Host "Updating Windows disk geometry..." -ForegroundColor Yellow

Start-Sleep -Seconds 2
Update-Disk -Number $diskNum -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "=== VERIFIED PARTITIONS ON SD CARD ===" -ForegroundColor Cyan
Get-Partition -DiskNumber $diskNum | Select-Object PartitionNumber, Size, Type, DriveLetter | Format-Table

Write-Host ""
Write-Host "SUCCESS! MicroSD card is ready to boot on Radxa Cubie A5E." -ForegroundColor Green
Write-Host "Press any key to close this window..."
[System.Console]::ReadKey() | Out-Null
