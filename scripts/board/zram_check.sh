#!/bin/bash
echo '=== zramswap sizing logic ==='
sed -n '1,120p' /usr/sbin/zramswap 2>/dev/null || sed -n '1,120p' /usr/bin/zramswap 2>/dev/null
echo '=== /etc/default/zramswap full ==='
cat /etc/default/zramswap 2>/dev/null
echo '=== zram module params ==='
cat /sys/module/zram/parameters/* 2>/dev/null
echo '=== disksize zram0 ==='
cat /sys/block/zram0/disksize 2>/dev/null
cat /sys/block/zram0/mem_limit 2>/dev/null
