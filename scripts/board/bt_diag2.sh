#!/bin/bash
echo '=== rfkill ==='
for r in /sys/class/rfkill/*; do [ -e "$r" ] || continue; echo "$(basename $r) name=$(cat $r/name) type=$(cat $r/type) soft=$(cat $r/soft) hard=$(cat $r/hard)"; done
echo '=== unblock bt ==='
echo 0 > /sys/class/rfkill/rfkill1/soft 2>/dev/null
for r in /sys/class/rfkill/*; do [ -e "$r" ] || continue; echo "$(basename $r) name=$(cat $r/name) soft=$(cat $r/soft)"; done
sleep 1
echo '=== bt_test (10s) ==='
timeout 10 /usr/local/sbin/bt_test -s uart 1500000 /dev/ttyAS1; echo "rc=$?"
echo '=== dmesg ==='
dmesg 2>/dev/null | grep -iE 'aic_bluetooth|rfkill|bt|ttyAS1|uart' | tail -15
