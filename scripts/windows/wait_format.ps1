$log = 'C:\Users\akant\AppData\Local\Temp\opencode\format_card.log'
$n = 0
while ($n -lt 300) {
    if (Test-Path $log) {
        if (Select-String -Path $log -Pattern 'FORMAT DONE' -Quiet -ErrorAction SilentlyContinue) { break }
    }
    Start-Sleep -Seconds 2
    $n += 2
}
if (Test-Path $log) { Get-Content $log } else { Write-Host "NO LOG - elevated script never ran (UAC not accepted?)" }
Write-Host "---CURRENT---"
Get-Partition -DiskNumber 2 -ErrorAction SilentlyContinue | Select-Object PartitionNumber,DriveLetter,Offset,Size,Type | Format-Table -AutoSize
