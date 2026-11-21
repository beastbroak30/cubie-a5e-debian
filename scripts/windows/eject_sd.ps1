$ErrorActionPreference = "Continue"

Write-Host "=== DISK 2 / VOLUMES ==="
Get-Partition -DiskNumber 2 | Select-Object PartitionNumber,DriveLetter,Offset,Size | Format-Table -AutoSize

$letters = @()
foreach ($p in (Get-Partition -DiskNumber 2)) {
    if ($p.DriveLetter) { $letters += $p.DriveLetter }
}
Write-Host ("drive letters on disk 2: {0}" -f ($(if ($letters.Count) { $letters -join ',' } else { 'none' })))

if ($letters.Count -eq 0) {
    Write-Host "No mounted volume to eject (already offline from Windows view)."
    Write-Host "Drive E: present? " + (Test-Path 'E:\')
} else {
    $shell = New-Object -ComObject Shell.Application
    foreach ($l in $letters) {
        $drv = "${l}:"
        Write-Host "Ejecting $drv ..."
        $item = $shell.Namespace(17).ParseName($drv)
        if ($item) {
            $item.InvokeVerb('Eject')
            Write-Host "  eject verb sent"
        } else {
            Write-Host "  drive object not found in My Computer"
        }
    }
}

Start-Sleep -Seconds 4
Write-Host "=== AFTER ==="
Get-Disk -Number 2 | Select-Object Number,FriendlyName,Size,PartitionStyle | Format-List
Write-Host ("E: exists now: {0}" -f (Test-Path 'E:\'))
Get-Partition -DiskNumber 2 | Select-Object PartitionNumber,DriveLetter,Offset,Size | Format-Table -AutoSize
Write-Host "=== DONE ==="
