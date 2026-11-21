#!/bin/bash
echo '=== ttyAS1 ==='
ls -l /dev/ttyAS1
stty -F /dev/ttyAS1 -a 2>&1 | head -3
echo '=== btlpm present ==='
modprobe aic8800_btlpm 2>&1
sleep 2
lsmod | grep -i btlpm
echo '=== bt_test raw ==='
timeout 6 /usr/local/sbin/bt_test -s uart 1500000 /dev/ttyAS1 2>&1 | head -60
echo "exit=$?"
echo '=== dmesg tail ==='
dmesg 2>/dev/null | tail -25
