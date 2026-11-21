#!/bin/bash
echo '=== links ==='
ip -br link show eth0; ip -br link show eth1
for d in eth0 eth1; do echo "--- $d"; ethtool "$d" 2>/dev/null | grep -E 'Speed|Duplex|Link detected|Auto-negotiation' || echo 'ethtool missing'; done
echo '=== dmesg eth ==='
dmesg 2>/dev/null | grep -iE 'eth0|eth1|stmmac|dwmac|phy' | tail -15
echo '=== nmcli ==='
nmcli -t dev status
