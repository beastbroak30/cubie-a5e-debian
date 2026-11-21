#!/bin/bash
set -x
hciconfig -a 2>&1 | head -20
ls /sys/class/bluetooth/ 2>&1
bluetoothctl list 2>&1 | head -5
systemctl is-active bluetooth
lsmod | grep -iE 'bt|bluetooth'
cat /proc/swaps
cat /etc/default/zramswap | grep -E 'PERCENTAGE|SIZE|ALGO'
free -m | head -2
echo '--- bt firmware ---'
ls /lib/firmware/aic8800*bt* /lib/firmware/aic8800d80/*bt* 2>/dev/null | head
