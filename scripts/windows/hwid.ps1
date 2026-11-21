$k = "HKLM:\SYSTEM\CurrentControlSet\Enum\USB\VID_1D6B&PID_0104&MI_00\6&202B6536&0&0000"
(Get-ItemProperty $k).HardwareID
(Get-ItemProperty $k).DeviceDesc
Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Enum\USB\VID_1D6B&PID_0104" | ForEach-Object { $_.PSChildName }
Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Enum\USB" | Where-Object { $_.PSChildName -like "VID_1D6B*" } | ForEach-Object { $_.PSChildName }
