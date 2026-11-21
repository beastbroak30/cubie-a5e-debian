$ErrorActionPreference = 'Continue'
$log = 'C:\Users\akant\AppData\Local\Temp\opencode\rndis_driver.log'
Start-Transcript -Path $log -Force | Out-Null

Write-Host "=== CURRENT RNDIS DEVICE STATUS ==="
$dev = Get-PnpDevice | Where-Object { $_.InstanceId -like "*1D6B*MI_00*" }
$dev | Format-List InstanceId, FriendlyName, Class, Status, Problem, ProblemDescription

Write-Host "=== LOOKING FOR BUILT-IN WINDOWS RNDIS DRIVER ==="
# Driver search in Windows DriverStore
$drivers = Get-ChildItem -Path C:\Windows\System32\DriverStore\FileRepository -Filter "*rndis*" -Recurse -ErrorAction SilentlyContinue
$drivers | Select-Object FullName

Stop-Transcript | Out-Null
