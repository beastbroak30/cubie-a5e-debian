Get-PnpDevice | Where-Object { $_.InstanceId -like "*1D6B*MI_00*" } | Format-List InstanceId, FriendlyName, Class, Status
Get-NetAdapter | Format-Table Name, InterfaceDescription, Status, LinkSpeed
