Start-Sleep -Seconds 2
Get-Disk | Format-Table Number, FriendlyName, BusType, Size, PartitionStyle, OperationalStatus
usbipd list
