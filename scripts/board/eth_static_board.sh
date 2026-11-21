#!/bin/bash
nmcli dev set eth1 managed no 2>&1
ip addr flush dev eth1 2>/dev/null
ip addr add 10.56.0.1/24 dev eth1 2>&1
ip link set eth1 up
sleep 2
ip -br addr show eth1
ip route | grep 10.56 || true
echo '--- ping windows ---'
ping -c 3 -W 2 10.56.0.2
echo '--- arp ---'
ip neigh show dev eth1
