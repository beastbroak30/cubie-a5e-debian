$ErrorActionPreference = "Stop"

$logFile = "C:\Users\akant\AppData\Local\Temp\opencode\flash_sd.log"
Start-Transcript -Path $logFile -Force

$imagePath = "D:\misc_prj\radxa_firmware\cubie-a5e-lite-arm64.img"
$diskNumber = 2
$drivePath = "\\.\PhysicalDrive$diskNumber"

Write-Host "=== Flashing Radxa Cubie A5E Firmware (Elevated) ==="
Write-Host "Source: $imagePath"
Write-Host "Target: $drivePath"

$imageFile = [System.IO.File]::OpenRead($imagePath)
$imageLength = $imageFile.Length
Write-Host "Image size: $imageLength bytes ($([math]::Round($imageLength / 1MB, 2)) MB)"

# Open disk stream
$driveStream = New-Object System.IO.FileStream(
    $drivePath,
    [System.IO.FileMode]::Open,
    [System.IO.FileAccess]::Write,
    [System.IO.FileShare]::ReadWrite
)

$bufferSize = 4 * 1024 * 1024 # 4MB buffer
$buffer = New-Object byte[] $bufferSize
$totalWritten = [long]0
$sw = [System.Diagnostics.Stopwatch]::StartNew()

try {
    while (($bytesRead = $imageFile.Read($buffer, 0, $bufferSize)) -gt 0) {
        $driveStream.Write($buffer, 0, $bytesRead)
        $totalWritten += $bytesRead
        
        $percent = [math]::Round(($totalWritten / $imageLength) * 100, 1)
        $mbWritten = [math]::Round($totalWritten / 1MB, 1)
        $speed = [math]::Round($mbWritten / [math]::Max($sw.Elapsed.TotalSeconds, 0.001), 1)
        
        if (($totalWritten % (64 * 1024 * 1024)) -eq 0 -or $totalWritten -eq $imageLength) {
            Write-Host "Written: $mbWritten MB ($percent%) at $speed MB/s"
        }
    }
    
    $driveStream.Flush()
    Write-Host "Syncing disk buffers..."
} finally {
    $driveStream.Close()
    $imageFile.Close()
}

$sw.Stop()
Write-Host "=== Flashing Complete in $([math]::Round($sw.Elapsed.TotalSeconds, 1)) seconds ==="
Write-Host "Re-reading partition table..."
Update-Disk -Number $diskNumber -ErrorAction SilentlyContinue
Get-Partition -DiskNumber $diskNumber | Select-Object PartitionNumber, Size, Type, DriveLetter

Stop-Transcript
Write-Host "FINISHED_FLASHING_OK"
