#!/bin/bash
echo '=== uptime / load ==='
uptime
echo '=== memory ==='
free -m
echo '=== swap ==='
cat /proc/swaps
echo '=== cpu ==='
nproc
grep -c '^processor' /proc/cpuinfo
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null
cat /sys/class/thermal/thermal_zone*/type 2>/dev/null | head -3
for z in /sys/class/thermal/thermal_zone*; do echo "$(basename $z) $(cat $z/type 2>/dev/null) $(cat $z/temp 2>/dev/null)"; done 2>/dev/null | head -5
echo '=== disk ==='
df -h / /tmp /boot 2>/dev/null
echo '=== boot time ==='
systemd-analyze 2>/dev/null | head -3
echo '=== top 8 by cpu ==='
ps -eo pcpu,pmem,rss,comm --sort=-pcpu | head -9
echo '=== top 8 by mem ==='
ps -eo pcpu,pmem,rss,comm --sort=-rss | head -9
echo '=== process count ==='
ps -e --no-headers | wc -l
echo '=== enabled services ==='
systemctl list-units --type=service --state=running --no-legend --no-pager | awk '{print $1}' | tr '\n' ' '
echo
echo '=== 5s load sample ==='
cat /proc/loadavg
sleep 5
cat /proc/loadavg
grep 'cpu ' /proc/stat
fun() { :; }
