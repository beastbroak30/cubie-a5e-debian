$pat = 'opencode\\(flash_sd|flash2|format_card|direct_flash|run_flash|wait_flash|wait_format)'
$procs = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -and $_.CommandLine -match $pat }
if (-not $procs) { Write-Host "no leftover flasher/format processes" }
foreach ($p in $procs) {
    Write-Host ("killing PID {0} : {1}" -f $p.ProcessId, $p.CommandLine)
    try { Stop-Process -Id $p.ProcessId -Force -ErrorAction Stop; Write-Host "  killed" } catch { Write-Host "  kill failed: $_" }
}
Write-Host "---DISK 2---"
Get-Disk -Number 2 | Select-Object Number,FriendlyName,Size,PartitionStyle,IsOffline,IsReadOnly | Format-List
Get-Partition -DiskNumber 2 -ErrorAction SilentlyContinue | Select-Object PartitionNumber,DriveLetter,Offset,Size,Type | Format-Table -AutoSize
Write-Host "---STOPPED---"
