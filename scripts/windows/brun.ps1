param([string]$Script, [string]$Args = '')
$k = 'C:\Users\akant\.ssh\cubie_a5e'
$o = '-o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL -o ConnectTimeout=20'
$local = "C:\Users\akant\AppData\Local\Temp\opencode\$Script"
& cmd /c "scp -i $k $o `"$local`" radxa@10.55.0.1:/tmp/$Script" 2>&1 | Out-Null
& cmd /c "ssh -i $k $o radxa@10.55.0.1 `"echo radxa | sudo -S bash /tmp/$Script $Args 2>&1`""
