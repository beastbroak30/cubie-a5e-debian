#!/bin/bash
D=/tmp/cubie-manifest
rm -rf "$D"; mkdir -p "$D"
{
  echo "generated: $(date -u +%FT%TZ)"
  echo "kernel: $(uname -r)"
  echo "cmdline: $(cat /proc/cmdline)"
  echo "hostname: $(hostname)"
  echo "dtb: $(ls /boot/*.dtb 2>/dev/null | tr '\n' ' ')"
  echo "model: $(cat /proc/device-tree/model 2>/dev/null | tr -d '\0')"
  echo "compatible: $(cat /proc/device-tree/compatible 2>/dev/null | tr -d '\0' | tr '\0' ' ')"
} > "$D/system.txt"

dpkg --get-selections > "$D/dpkg-selections.txt"
dpkg -l | awk '/^ii/{print $2, $3}' > "$D/dpkg-installed.txt"
systemctl list-unit-files > "$D/unit-files.txt"
systemctl list-units --type=service --state=running --no-legend > "$D/running-units.txt"
ip -d addr > "$D/ip-addr.txt" 2>&1
ip route > "$D/ip-route.txt"
ls -l /dev/gpiochip* > "$D/gpiochips.txt" 2>&1
for c in /sys/bus/gpio/devices/*; do
  [ -e "$c" ] || continue
  echo "--- $(basename $c) label=$(cat $c/label 2>/dev/null) base=$(cat $c/base 2>/dev/null) ngpio=$(cat $c/ngpio 2>/dev/null)" >> "$D/gpiochips.txt"
done
mount | grep -vE 'cgroup|proc|sys|devpts|mqueue|hugetlb|debugfs|tracefs|bpf|pstore|configfs|fusectl|securityfs' > "$D/mounts.txt"
lsmod > "$D/lsmod.txt"
ls /dev/i2c-* /dev/spidev* /dev/ttyAS* /dev/serial1 /dev/gpiomem* > "$D/devices.txt" 2>&1

tar czf /tmp/cubie-etc.tar.gz -C / etc/systemd/network etc/NetworkManager etc/default/zramswap etc/fstab etc/hostname etc/hostname etc/modules-load.d etc/apt/sources.list etc/apt/sources.list.d 2>/dev/null
tar czf /tmp/cubie-manifest.tar.gz -C /tmp cubie-manifest
ls -lh /tmp/cubie-manifest.tar.gz /tmp/cubie-etc.tar.gz
