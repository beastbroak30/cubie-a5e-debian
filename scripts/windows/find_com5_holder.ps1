Get-CimInstance Win32_Process | Where-Object { $_.Name -match 'powershell|putty|teraterm|python|alacritty|mobaxterm|plink|screen' } | Select-Object ProcessId, Name, @{n='Cmd';e={ if ($_.CommandLine.Length -gt 160) { $_.CommandLine.Substring(0,160) } else { $_.CommandLine } }} | Format-List
Get-PnpDevice -Class Ports -PresentOnly | Format-Table FriendlyName, Status
