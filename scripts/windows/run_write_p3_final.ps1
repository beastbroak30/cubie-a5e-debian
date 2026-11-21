$ErrorActionPreference = 'Stop'
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\write_p3_final.log'

Start-Transcript -Path $log -Force | Out-Null
Write-Host "=== FLASHING FULL FINAL P3 (WITH INITRD & UUID) TO DISK 2 ==="

$srcPath = 'C:\Users\akant\AppData\Local\Temp\opencode\p3_final.bin'
$diskPath = '\\.\PHYSICALDRIVE2'
$targetOffset = 348127232L # Sector 679936

$fi = [System.IO.FileInfo]::new($srcPath)
$totalBytes = [long]$fi.Length
Write-Host ("Source size: " + $totalBytes + " bytes (" + [math]::Round($totalBytes / 1GB, 2) + " GB)")
Write-Host ("Target offset: " + $targetOffset)

$csharp = @"
using System;
using System.IO;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;

public static class RawDiskWriter3 {
    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern SafeFileHandle CreateFile(
        string lpFileName,
        uint dwDesiredAccess,
        uint dwShareMode,
        IntPtr lpSecurityAttributes,
        uint dwCreationDisposition,
        uint dwFlagsAndAttributes,
        IntPtr hTemplateFile
    );

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool SetFilePointerEx(
        SafeFileHandle hFile,
        long liDistanceToMove,
        out long lpNewFilePointer,
        uint dwMoveMethod
    );

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool DeviceIoControl(
        SafeFileHandle hDevice,
        uint dwIoControlCode,
        IntPtr lpInBuffer,
        uint nInBufferSize,
        IntPtr lpOutBuffer,
        uint nOutBufferSize,
        out uint lpBytesReturned,
        IntPtr lpOverlapped
    );

    public const uint GENERIC_READ = 0x80000000;
    public const uint GENERIC_WRITE = 0x40000000;
    public const uint FILE_SHARE_READ = 0x00000001;
    public const uint FILE_SHARE_WRITE = 0x00000002;
    public const uint OPEN_EXISTING = 3;
    public const uint FSCTL_DISMOUNT_VOLUME = 0x00090020;
}
"@

Add-Type -TypeDefinition $csharp -PassThru | Out-Null

$hDisk = [RawDiskWriter3]::CreateFile(
    $diskPath,
    [RawDiskWriter3]::GENERIC_READ -bor [RawDiskWriter3]::GENERIC_WRITE,
    [RawDiskWriter3]::FILE_SHARE_READ -bor [RawDiskWriter3]::FILE_SHARE_WRITE,
    [IntPtr]::Zero,
    [RawDiskWriter3]::OPEN_EXISTING,
    0,
    [IntPtr]::Zero
)

if ($hDisk.IsInvalid) {
    throw ("Failed to open physical drive: " + [System.Runtime.InteropServices.Marshal]::GetLastWin32Error())
}

try {
    $bytesRet = 0
    [RawDiskWriter3]::DeviceIoControl($hDisk, [RawDiskWriter3]::FSCTL_DISMOUNT_VOLUME, [IntPtr]::Zero, 0, [IntPtr]::Zero, 0, [ref]$bytesRet, [IntPtr]::Zero) | Out-Null

    $newOffset = 0L
    if (-not [RawDiskWriter3]::SetFilePointerEx($hDisk, $targetOffset, [ref]$newOffset, 0)) {
        throw ("Failed to seek to offset: " + [System.Runtime.InteropServices.Marshal]::GetLastWin32Error())
    }

    Write-Host ("Seek confirmed at offset: " + $newOffset)

    $diskStream = [System.IO.FileStream]::new($hDisk, [System.IO.FileAccess]::ReadWrite)
    $srcStream = [System.IO.File]::OpenRead($srcPath)

    $bufSize = 8 * 1024 * 1024 # 8 MB
    $buf = New-Object byte[] $bufSize
    $written = 0L
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $lastReport = 0

    while ($written -lt $totalBytes) {
        $rem = $totalBytes - $written
        $toRead = if ($rem -lt [long]$bufSize) { [int]$rem } else { [int]$bufSize }
        $read = $srcStream.Read($buf, 0, $toRead)
        if ($read -le 0) { break }
        $diskStream.Write($buf, 0, $read)
        $written += $read

        if ($sw.Elapsed.TotalSeconds -gt ($lastReport + 5)) {
            $lastReport = $sw.Elapsed.TotalSeconds
            $pct = [math]::Round(($written / $totalBytes) * 100, 1)
            $speed = [math]::Round(($written / 1MB) / $sw.Elapsed.TotalSeconds, 1)
            Write-Host ("Flashing: " + $pct + "% (" + [math]::Round($written / 1MB) + " MB / " + [math]::Round($totalBytes / 1MB) + " MB at " + $speed + " MB/s)")
        }
    }

    $diskStream.Flush()
    $srcStream.Close()
    $diskStream.Close()

    Write-Host ("Flashing finished in " + [math]::Round($sw.Elapsed.TotalSeconds, 1) + " s! Total written: " + $written + " bytes")
} finally {
    if (-not $hDisk.IsClosed) {
        $hDisk.Close()
    }
}

Stop-Transcript | Out-Null
