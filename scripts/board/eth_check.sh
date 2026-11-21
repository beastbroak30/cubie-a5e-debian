#!/bin/bash
echo '=== /etc/systemd/network ==='
for f in /etc/systemd/network/*; do [ -f "$f" ] || continue; echo "--- $f"; cat "$f"; done
echo '=== NM unmanaged confs ==='
for f in /etc/NetworkManager/conf.d/*; do [ -f "$f" ] || continue; echo "--- $f"; cat "$f"; done
echo '=== eth links ==='
ip -br link show eth0; ip -br link show eth1
ethtool eth0 2>/dev/null | grep -E 'Speed|Duplex|Link detected|Auto'
echo '=== NM device detail eth0 ==='
nmcli -f GENERAL.DEVICE,GENERAL.STATE,GENERAL.CONNECTION,WIRED-PROPERTIES.CARRIER dev show eth0 2>&1
