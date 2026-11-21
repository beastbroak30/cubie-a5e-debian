#!/bin/bash
set -x
nmcli radio wifi on 2>&1
sleep 2
nmcli dev wifi list 2>&1 | head -12
nmcli dev wifi connect "akar" password "1234567ak" 2>&1
sleep 6
nmcli dev status 2>&1
ip -br addr show wlan0
ip route
ping -c 2 -W 3 1.1.1.1
ping -c 2 -W 3 deb.debian.org
