$ErrorActionPreference = "Stop"
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\patch_sd_card.log'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Elevating with administrator privileges..."
    Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',$PSCommandPath
    exit 0
}

Start-Transcript -Path $log -Force | Out-Null
Write-Host "=== TARGET DISK VERIFICATION ==="
$d = Get-Disk -Number 2
if ($d.FriendlyName -notlike "*xD/SD*" -and $d.BusType -ne "USB") {
    Write-Error "ABORT: Disk 2 does not appear to be the USB SD card reader! Name: $($d.FriendlyName), Bus: $($d.BusType)"
    exit 1
}
Write-Host ("Target disk: Number={0}, Name={1}, Size={2} GB, Bus={3}" -f $d.Number, $d.FriendlyName, [math]::Round($d.Size/1GB,2), $d.BusType)

$pkgPath = 'C:\Users\akant\AppData\Local\Temp\opencode\boot_package_ref.bin'
$pkgBytes = [System.IO.File]::ReadAllBytes($pkgPath)
Write-Host ("Boot package to write: {0} bytes ({1} MB)" -f $pkgBytes.Length, [math]::Round($pkgBytes.Length/1MB,2))

# Sector 24576 = offset 12582912 (12 MB)
$targetOffset = [int64](24576 * 512)
Write-Host ("Writing to sector 24576 (byte offset {0})..." -f $targetOffset)

# Set disk offline so Windows drops locks
Write-Host "Taking Disk 2 offline for exclusive raw write access..."
Set-Disk -Number 2 -IsOffline $true -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

$hDisk = [System.IO.File]::Open('\\.\PhysicalDrive2', [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::ReadWrite)
try {
    $hDisk.Seek($targetOffset, [System.IO.SeekOrigin]::Begin) | Out-Null
    $hDisk.Write($pkgBytes, 0, $pkgBytes.Length)
    $hDisk.Flush()
    Write-Host "Raw write succeeded."

    Write-Host "Verifying written bytes from card..."
    $hDisk.Seek($targetOffset, [System.IO.SeekOrigin]::Begin) | Out-Null
    $readBack = New-Object byte[] ($pkgBytes.Length)
    $totalRead = 0
    while ($totalRead -lt $pkgBytes.Length) {
        $n = $hDisk.Read($readBack, $totalRead, $pkgBytes.Length - $totalRead)
        if ($n -le 0) { break }
        $totalRead += $n
    }
    Write-Host ("Read back {0} bytes." -f $totalRead)
    
    $shaOrig = (Get-FileHash -Path $pkgPath -Algorithm SHA256).Hash
    $hasher = [System.Security.Cryptography.SHA256]::Create()
    $shaRead = -join ($hasher.ComputeHash($readBack) | ForEach-Object { '{0:X2}' -f $_ })
    Write-Host "Original hash: $shaOrig"
    Write-Host "Readback hash: $shaRead"
    if ($shaOrig -eq $shaRead) {
        Write-Host ">>> VERIFICATION PASSED: 100% BYTE MATCH <<<"
    } else {
        Write-Error "VERIFICATION FAILED: Hashes do not match!"
    }
} finally {
    $hDisk.Dispose()
    Write-Host "Bringing Disk 2 back online..."
    Set-Disk -Number 2 -IsOffline $false -ErrorAction SilentlyContinue
    Update-Disk -Number 2 -ErrorAction SilentlyContinue
}

# Eject
Write-Host "Ejecting card..."
Start-Sleep -Seconds 2
$shell = New-Object -ComObject Shell.Application
$p1 = Get-Partition -DiskNumber 2 -PartitionNumber 1 -ErrorAction SilentlyContinue
if ($p1 -and $p1.DriveLetter) {
    $item = $shell.Namespace(17).ParseName("$($p1.DriveLetter):")
    if ($item) { $item.InvokeVerb('Eject'); Write-Host "Ejected drive $($p1.DriveLetter):" }
}

Write-Host "=== FINISHED SUCCESSFULLY ==="
Stop-Transcript | Out-Null
