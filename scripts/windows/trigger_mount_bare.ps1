$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','C:\Users\akant\AppData\Local\Temp\opencode\mount_bare_run.ps1'
} else {
    & 'C:\Users\akant\AppData\Local\Temp\opencode\mount_bare_run.ps1'
}
