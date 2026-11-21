Write-Host "=== ALL DISKS ==="
Get-Disk | Select-Object Number,FriendlyName,Size,PartitionStyle,BusType,OperationalStatus | Format-Table -AutoSize
Write-Host "=== REMOVABLE VOLUMES ==="
Get-Volume | Where-Object { $_.DriveType -eq 'Removable' } | Select-Object DriveLetter,FileSystemLabel,FileSystem,Size | Format-Table -AutoSize
Write-Host "=== CARD READER PRESENT? ==="
$d = Get-Disk | Where-Object { $_.FriendlyName -like '*xD/SD*' -or $_.FriendlyName -like '*Card*' }
if ($d) { $d | Format-List } else { Write-Host "card reader not enumerated (card ejected / reader idle)" }
Write-Host "=== usbipd ==="
usbipd list 2>$null
Write-Host "=== DONE ==="
