$ErrorActionPreference = 'Continue'
$k = 'C:\Users\akant\.ssh\cubie_a5e'
$o = '-o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL -o ConnectTimeout=20'
$t = 'C:\Users\akant\AppData\Local\Temp\opencode'
& cmd /c "scp -i $k $o `"$t\bt_test`" `"$t\bt_up.sh`" radxa@10.55.0.1:/tmp/" 2>&1 | Select-Object -Last 2
& cmd /c "ssh -i $k $o radxa@10.55.0.1 `"echo radxa | sudo -S bash /tmp/bt_up.sh 2>&1`""
