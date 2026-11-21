$ErrorActionPreference = 'Stop'
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\write_p3_ncm.log'
Start-Transcript -Path $log -Force | Out-Null

$srcPath      = 'C:\Users\akant\AppData\Local\Temp\opencode\p3_ncm.bin'
$diskPath     = '\\.\PHYSICALDRIVE2'
$targetOffset = 348127232L   # sector 679936, P3 start

Write-Host "=== FLASH P3 (NCM gadget + initrd) -> DISK 2 ==="

# --- sanity: confirm target disk looks like the 128 GB SD card ---
$d = Get-Disk -Number 2
Write-Host ("Disk 2: " + $d.FriendlyName + " | size " + [math]::Round($d.Size/1GB,1) + " GB | bus " + $d.BusType)
if ($d.Size -lt 100GB) { throw "Disk 2 is not the 128 GB SD card. Aborting." }

$fi = [System.IO.FileInfo]::new($srcPath)
if (-not $fi.Exists) { throw "Source image missing: $srcPath" }
$totalBytes = [long]$fi.Length
Write-Host ("Source: " + $totalBytes + " bytes (" + [math]::Round($totalBytes/1GB,2) + " GiB)")
if ($totalBytes -lt 3900000000L) { throw "Source image too small - dump truncated. Aborting." }

$csharp = @"
using System;
using System.IO;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;

public static class RawDiskWriterN {
    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern SafeFileHandle CreateFile(string lpFileName, uint dwDesiredAccess, uint dwShareMode,
        IntPtr lpSecurityAttributes, uint dwCreationDisposition, uint dwFlagsAndAttributes, IntPtr hTemplateFile);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool SetFilePointerEx(SafeFileHandle hFile, long liDistanceToMove, out long lpNewFilePointer, uint dwMoveMethod);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool DeviceIoControl(SafeFileHandle hDevice, uint dwIoControlCode,
        IntPtr lpInBuffer, uint nInBufferSize, IntPtr lpOutBuffer, uint nOutBufferSize, out uint lpBytesReturned, IntPtr lpOverlapped);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool ReadFile(SafeFileHandle hFile, byte[] lpBuffer, uint nNumberOfBytesToRead, out uint lpNumberOfBytesRead, IntPtr lpOverlapped);

    public const uint GENERIC_READ = 0x80000000;
    public const uint GENERIC_WRITE = 0x40000000;
    public const uint FILE_SHARE_READ = 0x00000001;
    public const uint FILE_SHARE_WRITE = 0x00000002;
    public const uint OPEN_EXISTING = 3;
    public const uint FSCTL_DISMOUNT_VOLUME = 0x00090020;
    public const uint FSCTL_LOCK_VOLUME = 0x00090018;
}
"@
Add-Type -TypeDefinition $csharp -PassThru | Out-Null

$hDisk = [RawDiskWriterN]::CreateFile($diskPath,
    [RawDiskWriterN]::GENERIC_READ -bor [RawDiskWriterN]::GENERIC_WRITE,
    [RawDiskWriterN]::FILE_SHARE_READ -bor [RawDiskWriterN]::FILE_SHARE_WRITE,
    [IntPtr]::Zero, [RawDiskWriterN]::OPEN_EXISTING, 0, [IntPtr]::Zero)

if ($hDisk.IsInvalid) {
    throw ("Failed to open physical drive: " + [System.Runtime.InteropServices.Marshal]::GetLastWin32Error())
}

try {
    $bytesRet = 0
    [RawDiskWriterN]::DeviceIoControl($hDisk, [RawDiskWriterN]::FSCTL_LOCK_VOLUME, [IntPtr]::Zero, 0, [IntPtr]::Zero, 0, [ref]$bytesRet, [IntPtr]::Zero) | Out-Null
    [RawDiskWriterN]::DeviceIoControl($hDisk, [RawDiskWriterN]::FSCTL_DISMOUNT_VOLUME, [IntPtr]::Zero, 0, [IntPtr]::Zero, 0, [ref]$bytesRet, [IntPtr]::Zero) | Out-Null

    $newOffset = 0L
    if (-not [RawDiskWriterN]::SetFilePointerEx($hDisk, $targetOffset, [ref]$newOffset, 0)) {
        throw ("Seek failed: " + [System.Runtime.InteropServices.Marshal]::GetLastWin32Error())
    }
    Write-Host ("Seek confirmed at " + $newOffset)

    $diskStream = [System.IO.FileStream]::new($hDisk, [System.IO.FileAccess]::ReadWrite)
    $srcStream  = [System.IO.File]::OpenRead($srcPath)

    $bufSize = 8 * 1024 * 1024
    $buf = New-Object byte[] $bufSize
    $written = 0L
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $lastReport = 0.0

    while ($written -lt $totalBytes) {
        $rem = $totalBytes - $written
        $toRead = if ($rem -lt [long]$bufSize) { [int]$rem } else { $bufSize }
        $read = $srcStream.Read($buf, 0, $toRead)
        if ($read -le 0) { break }
        $diskStream.Write($buf, 0, $read)
        $written += $read
        if ($sw.Elapsed.TotalSeconds -gt ($lastReport + 5)) {
            $lastReport = $sw.Elapsed.TotalSeconds
            $pct = [math]::Round(($written / $totalBytes) * 100, 1)
            $speed = [math]::Round(($written / 1MB) / $sw.Elapsed.TotalSeconds, 1)
            Write-Host ("Flashing: $pct% (" + [math]::Round($written/1MB) + " MB / " + [math]::Round($totalBytes/1MB) + " MB at $speed MB/s)")
        }
    }

    $diskStream.Flush()
    $srcStream.Close()
    $diskStream.Close()
    Write-Host ("Write done in " + [math]::Round($sw.Elapsed.TotalSeconds,1) + " s, " + $written + " bytes")

    # --- verify: re-seek and read back first 4 KiB, compare with source head ---
    $h2 = [RawDiskWriterN]::CreateFile($diskPath, [RawDiskWriterN]::GENERIC_READ,
        [RawDiskWriterN]::FILE_SHARE_READ -bor [RawDiskWriterN]::FILE_SHARE_WRITE,
        [IntPtr]::Zero, [RawDiskWriterN]::OPEN_EXISTING, 0, [IntPtr]::Zero)
    $p = 0L
    [RawDiskWriterN]::SetFilePointerEx($h2, $targetOffset, [ref]$p, 0) | Out-Null
    $head = New-Object byte[] 4096
    $got = 0
    [RawDiskWriterN]::ReadFile($h2, $head, 4096, [ref]$got, [IntPtr]::Zero) | Out-Null
    $h2.Close()

    $srcHead = New-Object byte[] 4096
    $fs = [System.IO.File]::OpenRead($srcPath)
    $fs.Read($srcHead, 0, 4096) | Out-Null
    $fs.Close()

    $same = $true
    for ($i = 0; $i -lt 4096; $i++) { if ($head[$i] -ne $srcHead[$i]) { $same = $false; break } }
    Write-Host ("Readback head match: " + $same + " (bytes read: " + $got + ")")
} finally {
    if (-not $hDisk.IsClosed) { $hDisk.Close() }
}

Stop-Transcript | Out-Null
