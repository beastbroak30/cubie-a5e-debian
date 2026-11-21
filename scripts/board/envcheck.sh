#!/usr/bin/env bash
set -u
echo "=== identity ==="
id
echo "user=$(getent passwd 1000 | cut -d: -f1)"
echo "home=$(getent passwd 1000 | cut -d: -f6)"
echo "pwd=$PWD"
echo "=== kernel ==="
uname -a
echo "=== cpu ==="
nproc
grep -m1 'model name' /proc/cpuinfo
echo "=== mem ==="
free -h
echo "=== disk ==="
df -h / /tmp /root 2>/dev/null
echo "=== filesystem type of cwd ==="
stat -f -c '%T %b*%S' /mnt/d 2>/dev/null
echo "=== tools ==="
for t in debootstrap qemu-aarch64-static qemu-aarch64 aarch64-linux-gnu-gcc dtc parted losetup sgdisk mkfs.vfat mkfs.ext4 wget curl git rsync ssh-keygen; do
  printf '%-24s %s\n' "$t" "$(command -v "$t" || echo MISSING)"
done
echo "=== apt cache ==="
apt-cache policy debootstrap 2>/dev/null | head -3
echo "=== net ==="
timeout 15 curl -sI https://deb.debian.org/debian/ | head -2
timeout 15 curl -sI https://apt.radxa.com/ 2>/dev/null | head -2
