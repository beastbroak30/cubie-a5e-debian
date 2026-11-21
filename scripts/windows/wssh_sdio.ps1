$ErrorActionPreference = 'Continue'
$k = 'C:\Users\akant\.ssh\cubie_a5e'
$o = '-o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL -o ConnectTimeout=15'
$q = 'echo "--- sdio devices ---"; for d in /sys/bus/sdio/devices/*; do echo "$d"; cat $d/uevent 2>/dev/null; cat $d/vendor $d/device 2>/dev/null; echo; done 2>/dev/null; echo "--- mmc ---"; ls /sys/class/mmc_host; echo "--- dmesg mmc ---"; dmesg 2>/dev/null | grep -iE "mmc|sdio" | tail -25'
& cmd /c "ssh -i $k $o radxa@10.55.0.1 `"echo radxa | sudo -S bash -c '$q' 2>&1`""
