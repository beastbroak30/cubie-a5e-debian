$disk = Get-Disk | Where-Object { $_.Number -eq 2 }
$disk | Format-List Number, FriendlyName, OperationalStatus, Size
$p = Get-Partition -DiskNumber 2
$p | Format-Table DiskNumber, PartitionNumber, DriveLetter, Size, Type
