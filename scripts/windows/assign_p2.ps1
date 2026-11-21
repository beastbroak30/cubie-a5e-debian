$p = Get-Partition -DiskNumber 2 -PartitionNumber 2
if (-not $p.DriveLetter) {
    Set-Partition -DiskNumber 2 -PartitionNumber 2 -NewDriveLetter F
}
Get-ChildItem -Recurse F:\ | Format-Table FullName, Length
