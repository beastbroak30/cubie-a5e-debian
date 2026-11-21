$exe    = 'D:\misc_prj\radxa_firmware\balenaEtcher-2.1.9.Setup.exe'
$img    = 'D:\misc_prj\radxa_firmware\cubie-a5e-lite-arm64.img'
$expectExe = '3FA63EA453E75C0338F8F1444B511F38DECDD002E17922A910AEC5E29B85B751'
$expectImg = '10CA7DF1429A01713F48E8AFFC0F6BBB46AE33BEF39CDA69441A69512597BC7A'

Write-Host "=== FILES IN D:\misc_prj\radxa_firmware ==="
Get-ChildItem 'D:\misc_prj\radxa_firmware' | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize

$e = Get-Item $exe
$h = (Get-FileHash -Algorithm SHA256 $exe).Hash
Write-Host ""
Write-Host "Etcher installer : $exe"
Write-Host "  size   : $($e.Length) bytes"
Write-Host "  sha256 : $h"
Write-Host "  expect : $expectExe"
Write-Host "  match  : $($h -eq $expectExe)"

$i = Get-Item $img
$hi = (Get-FileHash -Algorithm SHA256 $img).Hash
Write-Host ""
Write-Host "Firmware image   : $img"
Write-Host "  size   : $($i.Length) bytes"
Write-Host "  sha256 : $hi"
Write-Host "  expect : $expectImg"
Write-Host "  match  : $($hi -eq $expectImg)"
Write-Host "=== VERIFY DONE ==="
