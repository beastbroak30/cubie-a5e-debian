#!/bin/bash
set -x
export DEBIAN_FRONTEND=noninteractive
apt-get install -y systemd-timesyncd >/dev/null 2>&1
systemctl enable --now systemd-timesyncd 2>&1
sleep 5
timedatectl | head -6
apt-get install -y iw wireless-tools wpasupplicant >/dev/null 2>&1
command -v iw iwconfig wpa_supplicant
echo '--- iw dev ---'
iw dev 2>&1 | head -20
echo '--- iw list (nl80211) ---'
iw list 2>&1 | head -10
echo '--- proc wireless ---'
cat /proc/net/wireless
echo '--- iwconfig ---'
iwconfig 2>&1 | head -20
echo '--- scan via iw ---'
iw dev wlan0 scan 2>&1 | head -20
