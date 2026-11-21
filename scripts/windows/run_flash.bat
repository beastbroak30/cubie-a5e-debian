@echo off
echo ========================================================
echo   Radxa Cubie A5E SD Card Flasher (Admin Console)
echo ========================================================
echo Source Image: D:\misc_prj\radxa_firmware\cubie-a5e-lite-arm64.img
echo Target Drive: \\.\PhysicalDrive2 (Disk 2, 128GB MicroSD)
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$src = 'D:\misc_prj\radxa_firmware\cubie-a5e-lite-arm64.img'; " ^
  "$dst = '\\.\PhysicalDrive2'; " ^
  "Write-Host 'Opening source and target...' -ForegroundColor Cyan; " ^
  "$fsIn = [System.IO.File]::OpenRead($src); " ^
  "$len = $fsIn.Length; " ^
  "$fsOut = New-Object System.IO.FileStream($dst, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Write, [System.IO.FileShare]::ReadWrite); " ^
  "$buf = New-Object byte[] (4 * 1024 * 1024); " ^
  "$tot = [long]0; " ^
  "$sw = [System.Diagnostics.Stopwatch]::StartNew(); " ^
  "while(($n = $fsIn.Read($buf, 0, $buf.Length)) -gt 0) { " ^
  "    $fsOut.Write($buf, 0, $n); " ^
  "    $tot += $n; " ^
  "    if ($tot % (128 * 1024 * 1024) -eq 0 -or $tot -eq $len) { " ^
  "        $mb = [math]::Round($tot / 1MB); " ^
  "        $pct = [math]::Round(($tot / $len) * 100); " ^
  "        $spd = [math]::Round($mb / [math]::Max($sw.Elapsed.TotalSeconds, 0.001), 1); " ^
  "        Write-Host ('[ ' + $pct + '%% ] ' + $mb + ' MB written at ' + $spd + ' MB/s') -ForegroundColor Green; " ^
  "    } " ^
  "}; " ^
  "$fsOut.Flush(); " ^
  "$fsOut.Close(); " ^
  "$fsIn.Close(); " ^
  "Write-Host 'Flushing finished. Updating disk table...' -ForegroundColor Yellow; " ^
  "Update-Disk -Number 2 -ErrorAction SilentlyContinue; " ^
  "Get-Partition -DiskNumber 2 | Select-Object PartitionNumber, Size, Type, DriveLetter | Format-Table; " ^
  "Write-Host 'SUCCESS! Flash completed.' -ForegroundColor Cyan; "

echo.
echo Flash completed. Press any key to exit.
pause > nul
