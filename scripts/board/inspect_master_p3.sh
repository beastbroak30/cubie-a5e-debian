#!/bin/bash
set -u
IMG=/home/akar/cubie-a5e-fw/output/cubie-a5e-lite-arm64.img
mkdir -p /mnt/p3m
L=$(losetup -fP --show "$IMG")
echo "LOOP=$L"
trap 'umount /mnt/p3m 2>/dev/null; losetup -d "$L" 2>/dev/null' EXIT
lsblk -b -o NAME,SIZE,START "$L" 2>/dev/null | head
echo '=== PARTITIONS ==='
for p in "${L}"p*; do echo "--- $p"; done
mount -o rw "${L}p3" /mnt/p3m || { echo MOUNT_FAIL; exit 1; }
echo '=== modules-load.d ==='
ls -l /mnt/p3m/etc/modules-load.d/ 2>&1
grep -r . /mnt/p3m/etc/modules-load.d/ 2>/dev/null
echo '=== usr/local/sbin ==='
ls -l /mnt/p3m/usr/local/sbin/ 2>&1
echo '=== usb-gadget-init.sh ==='
cat /mnt/p3m/usr/local/sbin/usb-gadget-init.sh 2>&1
echo '=== usb-gadget.service ==='
cat /mnt/p3m/etc/systemd/system/usb-gadget.service 2>&1
echo '=== systemd system dir ==='
ls /mnt/p3m/etc/systemd/system/ 2>&1
echo '=== getty wants ==='
ls -l /mnt/p3m/etc/systemd/system/getty.target.wants/ 2>&1
echo '=== boot ==='
ls -l /mnt/p3m/boot/ 2>&1
echo '=== extlinux ==='
cat /mnt/p3m/boot/extlinux/extlinux.conf 2>&1
echo '=== df ==='
df -h /mnt/p3m
echo '=== fstab ==='
cat /mnt/p3m/etc/fstab 2>&1
echo '=== networkd / NM ==='
ls /mnt/p3m/etc/systemd/network/ 2>&1
ls /mnt/p3m/etc/network/ 2>&1
cat /mnt/p3m/etc/network/interfaces 2>&1
echo '=== zram ==='
ls /mnt/p3m/etc/systemd/ 2>&1
