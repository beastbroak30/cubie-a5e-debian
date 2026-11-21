$disk = Get-Disk | Where-Object { $_.FriendlyName -like "*Realtek*" -or $_.BusType -eq "USB" }
$disk | Format-List Number, FriendlyName, BusType, Size, PartitionStyle, OperationalStatus
$vol = Get-Volume
$vol | Format-Table DriveLetter, FileSystemLabel, FileSystem, SizeRemaining, Size
