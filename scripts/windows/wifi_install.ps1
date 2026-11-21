$ErrorActionPreference = 'Continue'
$k = 'C:\Users\akant\.ssh\cubie_a5e'
$o = '-o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL -o ConnectTimeout=20'
$src = 'C:\Users\akant\AppData\Local\Temp\opencode\aic8800d80'
& cmd /c "scp -r -i $k $o `"$src`" radxa@10.55.0.1:/tmp/aic8800d80" 2>&1 | Select-Object -Last 3
& cmd /c "ssh -i $k $o radxa@10.55.0.1 `"echo radxa | sudo -S bash -c 'mkdir -p /lib/firmware/aic8800d80 && cp -f /tmp/aic8800d80/* /lib/firmware/aic8800d80/ && chmod 644 /lib/firmware/aic8800d80/* && ls /lib/firmware/aic8800d80 | wc -l'`""
& cmd /c "scp -i $k $o C:\Users\akant\AppData\Local\Temp\opencode\load_wifi.sh radxa@10.55.0.1:/tmp/load_wifi.sh" 2>&1 | Out-Null
& cmd /c "ssh -i $k $o radxa@10.55.0.1 `"echo radxa | sudo -S bash /tmp/load_wifi.sh 2>&1`""
