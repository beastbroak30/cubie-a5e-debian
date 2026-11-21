$ErrorActionPreference = 'Continue'
$k = 'C:\Users\akant\.ssh\cubie_a5e'
$o = '-o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL -o ConnectTimeout=20'
$t = 'C:\Users\akant\AppData\Local\Temp\opencode'
foreach ($f in @('cubie-manifest.tar.gz','cubie-etc.tar.gz')) {
    $remote = "radxa@10.55.0.1:/tmp/$f"
    $local  = Join-Path $t $f
    & cmd /c "scp -i $k $o $remote `"$local`""
}
Get-ChildItem "$t\cubie-*.tar.gz" | Select-Object Name,Length | Format-Table -AutoSize
