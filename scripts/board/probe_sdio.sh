#!/bin/bash
echo '--- sdio devices ---'
for d in /sys/bus/sdio/devices/*; do
  [ -e "$d" ] || continue
  echo "$d"
  cat "$d/uevent" 2>/dev/null
  echo "vendor=$(cat $d/vendor 2>/dev/null) device=$(cat $d/device 2>/dev/null)"
  echo
done
echo '--- mmc hosts ---'
ls /sys/class/mmc_host
echo '--- dmesg mmc/sdio ---'
dmesg 2>/dev/null | grep -iE 'mmc|sdio|aic|8852' | tail -30
echo '--- clock ---'
date -u
