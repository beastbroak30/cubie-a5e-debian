Get-ChildItem 'C:\Users\akant\AppData\Local\Temp\opencode' -Force |
    Sort-Object Length -Descending |
    Select-Object Name, @{n='MB'; e={ [math]::Round($_.Length / 1MB, 2) }}, LastWriteTime |
    Format-Table -AutoSize | Out-String -Width 140
