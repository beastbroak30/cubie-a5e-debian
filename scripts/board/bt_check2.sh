#!/bin/bash
echo "=== sys/class/bluetooth ==="
ls -l /sys/class/bluetooth/ 2>&1
echo "=== rfkill dirs ==="
for r in /sys/class/rfkill/*; do [ -e "$r" ] || continue; echo "$(basename $r) name=$(cat $r/name 2>/dev/null) type=$(cat $r/type 2>/dev/null) soft=$(cat $r/soft 2>/dev/null) hard=$(cat $r/hard 2>/dev/null)"; done
echo "=== uart attached ==="
ls -l /dev/ttyS* /dev/ttyAS* 2>&1 | head
echo "=== bsp/bt modules ==="
ls /lib/modules/5.15.147+/kernel/bsp/drivers/net/wireless/aic8800/sdio/aic8800_btlpm/ 2>&1
echo "=== bt fw in aic dir ==="
ls /lib/firmware/aic8800d80/ | grep -i bt
echo "=== dmesg bt ==="
dmesg 2>/dev/null | grep -iE 'bluetooth|hci|btlpm|aicbsp_bt' | tail -20
echo "=== zram ==="
cat /proc/swaps
grep -E 'PERCENTAGE|SIZE|ALGO' /etc/default/zramswap 2>/dev/null
free -m | head -2
