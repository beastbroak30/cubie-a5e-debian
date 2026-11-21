$ErrorActionPreference = 'Continue'
Write-Host "=== PROCESSES HOLDING COM PORTS ==="
Get-CimInstance Win32_Process -Filter "Name='powershell.exe' OR Name='pwsh.exe'" | Select-Object ProcessId, @{n='Cmd';e={$_.CommandLine}} | Format-List
