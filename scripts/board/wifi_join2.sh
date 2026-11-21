#!/bin/bash
set -x
nmcli dev wifi list 2>&1 | grep -i akar || echo "AKAR_NOT_IN_SCAN"
nmcli connection delete akar 2>/dev/null
nmcli connection add type wifi ifname wlan0 con-name akar ssid akar 2>&1
nmcli connection modify akar wifi-sec.key-mgmt wpa-psk wifi-sec.psk "1234567ak" 2>&1
nmcli connection modify akar connection.autoconnect yes 2>&1
nmcli connection up akar 2>&1
sleep 8
nmcli dev status 2>&1
ip -br addr show wlan0
ip route
ping -c 2 -W 3 1.1.1.1
