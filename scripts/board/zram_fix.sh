#!/bin/bash
set -x
sed -i 's/^PERCENTAGE=50/PERCENT=50/' /etc/default/zramswap
grep -vE '^#|^$' /etc/default/zramswap
systemctl restart zramswap.service 2>&1
sleep 2
cat /proc/swaps
cat /sys/block/zram0/disksize
cat /sys/block/zram0/comp_algorithm
