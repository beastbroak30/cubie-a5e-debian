#!/bin/bash
ip addr flush dev eth1 2>/dev/null || true
nmcli dev set eth1 managed yes 2>&1
sleep 6
ip -br addr show eth1
nmcli -f DEVICE,STATE,CONNECTION dev status | head -8
ip route | grep -c 10.56 || true
