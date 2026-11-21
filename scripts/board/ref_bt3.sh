#!/bin/bash
set -e
mkdir -p /mnt/refp3
L=$(losetup -fP --show /home/akar/cubie-a5e-fw/cache/ref.img)
trap 'umount /mnt/refp3 2>/dev/null; losetup -d "$L" 2>/dev/null' EXIT
partx -u "$L" 2>/dev/null
mount -o ro "${L}p3" /mnt/refp3
echo '=== udev rule ==='
cat /mnt/refp3/lib/udev/rules.d/99-aic8800-reset-ttyas1.rules
echo '=== bt_test deps ==='
ls -l /mnt/refp3/usr/bin/bt_test
file /mnt/refp3/usr/bin/bt_test 2>/dev/null
echo '=== aicrf-test list ==='
cat /mnt/refp3/var/lib/dpkg/info/aicrf-test.list 2>/dev/null
echo '=== cached debs ==='
ls /mnt/refp3/var/cache/apt/archives/*.deb 2>/dev/null | head -20
echo '=== rsetup python? ==='
head -1 /mnt/refp3/usr/bin/rsetup 2>/dev/null
file /mnt/refp3/usr/bin/rsetup 2>/dev/null
echo '=== bluez version in ref ==='
grep -m1 '^Version' /mnt/refp3/var/lib/dpkg/status 2>/dev/null >/dev/null
awk '/^Package: bluez$/{f=1} f&&/^Version:/{print; exit}' /mnt/refp3/var/lib/dpkg/status
echo '=== bluetooth.service ==='
cat /mnt/refp3/lib/systemd/system/bluetooth.service
echo '=== hciattach present ==='
ls -l /mnt/refp3/usr/bin/hciattach 2>/dev/null
