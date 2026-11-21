$ErrorActionPreference = 'Continue'
$k = 'C:\Users\akant\.ssh\cubie_a5e'
$o = '-o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL -o ConnectTimeout=15'
$q = 'echo "--- wireless modules built ---"; ls /lib/modules/5.15.147+/kernel/drivers/net/wireless/; echo "--- 8852 modules ---"; find /lib/modules/5.15.147+ -iname "*8852*"; echo "--- rtw89 fw ---"; ls /lib/firmware/rtw89 2>/dev/null | head -20; echo "--- all fw count ---"; ls /lib/firmware | wc -l; echo "--- aic fw ---"; find /lib/firmware -iname "*aic*" | head; echo "--- loaded ---"; lsmod | head -20'
& cmd /c "ssh -i $k $o radxa@10.55.0.1 `"$q`""
