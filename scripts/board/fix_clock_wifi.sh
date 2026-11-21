#!/bin/bash
set -x
date -u
timedatectl 2>&1 | head -8
systemctl enable --now systemd-timesyncd 2>&1
sleep 3
timedatectl status 2>&1 | head -8
echo '--- after sync ---'
date -u
echo '--- wifi firmware ---'
ls /lib/firmware | grep -i -E 'aic|8800' || echo NO_AIC_FW
ls /lib/firmware/aic8800* 2>/dev/null || true
find /lib/firmware -maxdepth 2 -iname '*aic*' | head
echo '--- rfkill via /sys ---'
for r in /sys/class/rfkill/*; do echo "$r: $(cat $r/name) type=$(cat $r/type) soft=$(cat $r/soft) hard=$(cat $r/hard)"; done
echo '--- nmcli ---'
nmcli -f WIFI-HW,WIFI,WWAN-HW,WWAN radio 2>&1
nmcli dev status 2>&1
echo '--- modules ---'
lsmod | grep -i -E 'aic|8852|brcm' || true
