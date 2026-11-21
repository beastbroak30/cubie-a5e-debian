Write-Host "=== DISK 2 ==="
Get-Disk -Number 2 | Select-Object Number,FriendlyName,Size,PartitionStyle,IsReadOnly,IsOffline | Format-List
Write-Host "=== PARTITIONS ==="
Get-Partition -DiskNumber 2 -ErrorAction SilentlyContinue | Select-Object PartitionNumber,DriveLetter,Offset,Size,Type | Format-Table -AutoSize
Write-Host "=== VOLUMES ON DISK 2 ==="
Get-Partition -DiskNumber 2 -ErrorAction SilentlyContinue | ForEach-Object {
    $v = Get-Volume -Partition $_ -ErrorAction SilentlyContinue
    if ($v) { [pscustomobject]@{ Part=$_.PartitionNumber; Letter=$v.DriveLetter; Label=$v.FileSystemLabel; FS=$v.FileSystem; SizeGB=[math]::Round($v.Size/1GB,2) } }
} | Format-Table -AutoSize
Write-Host "=== RAW HEADER SNIFF (sectors 0,1,256,24576) ==="
$fs = New-Object System.IO.FileStream('\\.\PhysicalDrive2',[System.IO.FileMode]::Open,[System.IO.FileAccess]::Read,[System.IO.FileShare]::ReadWrite,1MB)
try {
    $buf = New-Object byte[] (24576*512 + 512)
    $read = 0
    while ($read -lt $buf.Length) {
        $n = $fs.Read($buf, $read, $buf.Length - $read)
        if ($n -le 0) { break }
        $read += $n
    }
    $lba1 = [System.Text.Encoding]::ASCII.GetString($buf, 512, 8)
    $bt0  = [System.Text.Encoding]::ASCII.GetString($buf, 256*512, 16)
    $toc  = [System.Text.Encoding]::ASCII.GetString($buf, 24576*512, 13)
    Write-Host "LBA1  : '$lba1'  (expect EFI PART)"
    Write-Host "LBA256: '$($bt0 -replace '[^\x20-\x7e]','.')'  (expect eGON.BT0)"
    Write-Host "LBA24576: '$toc' (expect sunxi-package)"
    Write-Host "bytes read: $read"
} catch {
    Write-Host "raw read failed: $_"
} finally { $fs.Dispose() }
Write-Host "=== DONE ==="
