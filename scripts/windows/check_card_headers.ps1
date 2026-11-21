$ErrorActionPreference = 'Stop'
$diskPath = '\\.\PHYSICALDRIVE2'

$csharp = @"
using System;
using System.IO;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;

public static class RawDiskReader {
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

    public const uint GENERIC_READ = 0x80000000;
    public const uint FILE_SHARE_READ = 0x00000001;
    public const uint FILE_SHARE_WRITE = 0x00000002;
    public const uint OPEN_EXISTING = 3;
}
"@

Add-Type -TypeDefinition $csharp -PassThru | Out-Null

$hDisk = [RawDiskReader]::CreateFile(
    $diskPath,
    [RawDiskReader]::GENERIC_READ,
    [RawDiskReader]::FILE_SHARE_READ -bor [RawDiskReader]::FILE_SHARE_WRITE,
    [IntPtr]::Zero,
    [RawDiskReader]::OPEN_EXISTING,
    0,
    [IntPtr]::Zero
)

if ($hDisk.IsInvalid) {
    Write-Host "Card not present in reader."
    exit 0
}

try {
    $fs = [System.IO.FileStream]::new($hDisk, [System.IO.FileAccess]::Read)
    
    # Read sector 256 (boot0)
    $newOffset = 0L
    [RawDiskReader]::SetFilePointerEx($hDisk, (256L * 512L), [ref]$newOffset, 0) | Out-Null
    $b0 = New-Object byte[] 64
    $fs.Read($b0, 0, 64) | Out-Null
    $s0 = [System.Text.Encoding]::ASCII.GetString($b0, 4, 8)
    Write-Host "Sector 256 signature: $s0"

    # Read sector 24576 (TOC1)
    [RawDiskReader]::SetFilePointerEx($hDisk, (24576L * 512L), [ref]$newOffset, 0) | Out-Null
    $b1 = New-Object byte[] 64
    $fs.Read($b1, 0, 64) | Out-Null
    $s1 = [System.Text.Encoding]::ASCII.GetString($b1, 0, 8)
    Write-Host "Sector 24576 signature: $s1"
} finally {
    $hDisk.Close()
}
