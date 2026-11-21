$candidates = @(
    "$env:LOCALAPPDATA\Programs\balena-etcher\balenaEtcher.exe",
    "$env:ProgramFiles\balena-etcher\balenaEtcher.exe",
    "${env:ProgramFiles(x86)}\balena-etcher\balenaEtcher.exe",
    "$env:LOCALAPPDATA\Programs\balenaEtcher\balenaEtcher.exe"
)
foreach ($c in $candidates) {
    if (Test-Path $c) { Write-Host "FOUND: $c"; (Get-Item $c) | Select-Object FullName,Length,LastWriteTime | Format-List }
}
Write-Host "--- localappdata programs ---"
Get-ChildItem "$env:LOCALAPPDATA\Programs" -ErrorAction SilentlyContinue | Select-Object Name | Format-Table -AutoSize
Write-Host "--- start menu ---"
Get-ChildItem "$env:APPDATA\Microsoft\Windows\Start Menu\Programs" -Recurse -Filter '*tcher*' -ErrorAction SilentlyContinue | Select-Object FullName | Format-Table -AutoSize
Write-Host "--- running procs ---"
Get-Process -Name '*etcher*' -ErrorAction SilentlyContinue | Select-Object Id,ProcessName | Format-Table -AutoSize
Write-Host "DONE"
