#!/bin/bash
echo '=== try hciattach directly ==='
timeout 20 /usr/bin/hciattach -s 1500000 /dev/ttyAS1 any 1500000 flow nosleep 2>&1 | tail -20
echo "rc=$?"
sleep 2
ls /sys/class/bluetooth/ 2>&1
bluetoothctl list 2>&1 | head -3
echo '=== dmesg ==='
dmesg 2>/dev/null | grep -iE 'bluetooth|hci|rfkill|regon|chip_en' | tail -25
echo '=== dt nodes with bt ==='
ls /sys/firmware/devicetree/base/ | grep -iE 'bt|bluetooth|rfkill|uart' 
echo '=== rfkill dts contents ==='
for n in /sys/firmware/devicetree/base/*rfkill* /sys/firmware/devicetree/base/*bt*; do [ -e "$n" ] || continue; echo "--- $n"; ls "$n"; done
