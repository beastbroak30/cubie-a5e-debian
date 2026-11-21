$ErrorActionPreference = 'Continue'
$k = 'C:\Users\akant\.ssh\cubie_a5e'
$o = '-o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL -o ConnectTimeout=15'
& cmd /c "scp -i $k $o C:\Users\akant\AppData\Local\Temp\opencode\fix_clock_wifi.sh radxa@10.55.0.1:/tmp/fix_clock_wifi.sh" 2>&1 | Out-Null
& cmd /c "ssh -i $k $o radxa@10.55.0.1 `"echo radxa | sudo -S bash /tmp/fix_clock_wifi.sh 2>&1`""
