$ErrorActionPreference = "Continue"
Write-Host "=== DISKS ==="
Get-Disk | Select-Object Number,FriendlyName,Size,PartitionStyle,BusType,OperationalStatus | Format-Table -AutoSize
Write-Host "=== DISK 2 DETAILS ==="
Get-Disk -Number 2 -ErrorAction SilentlyContinue | Format-List
Write-Host "=== DISK 2 PARTITIONS ==="
Get-Partition -DiskNumber 2 -ErrorAction SilentlyContinue | Select-Object PartitionNumber,DriveLetter,Offset,Size,Type | Format-Table -AutoSize
