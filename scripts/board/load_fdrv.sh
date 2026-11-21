#!/bin/bash
set -x
modprobe aic8800_fdrv 2>&1
sleep 5
lsmod | grep aic
ip -br link
echo '--- dmesg aic ---'
dmesg 2>/dev/null | grep -iE 'aic|8800|wlan|cfg80211' | tail -60
echo '--- firmware loader ----'
cat /sys/module/firmware_class/parameters/path 2>/dev/null
