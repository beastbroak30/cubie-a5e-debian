Get-PnpDevice -PresentOnly | Where-Object { 
    $_.Class -match 'Ports|Net|USB|Modem' -or 
    $_.FriendlyName -match 'Gadget|RNDIS|Radxa|Android|Serial' 
} | Format-Table InstanceId, Class, FriendlyName, Status
