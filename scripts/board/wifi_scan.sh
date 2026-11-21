#!/bin/bash
set -x
ip link set wlan0 down
sleep 1
iw dev wlan0 scan 2>&1 | head -25
ip link set wlan0 up
sleep 1
nmcli dev wifi rescan 2>&1
sleep 4
nmcli dev wifi list 2>&1 | head -15
nmcli dev status
echo '--- rfkill ---'
for r in /sys/class/rfkill/*; do [ -e "$r" ] || continue; echo "$r $(cat $r/name 2>/dev/null) soft=$(cat $r/soft 2>/dev/null) hard=$(cat $r/hard 2>/dev/null)"; done
