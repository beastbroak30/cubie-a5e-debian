#!/bin/bash
set -u
IMG=/home/akar/cubie-a5e-fw/output/cubie-a5e-lite-arm64.img
mkdir -p /mnt/p3m
L=$(losetup -fP --show "$IMG")
trap 'umount /mnt/p3m 2>/dev/null; losetup -d "$L" 2>/dev/null' EXIT
mount -o rw "${L}p3" /mnt/p3m
M=/mnt/p3m
echo '=== 20-usb0.network ==='
cat $M/etc/systemd/network/20-usb0.network 2>&1
echo '=== networkd enabled? ==='
ls -l $M/etc/systemd/system/network-online.target.wants/ 2>&1
ls -l $M/etc/systemd/system/sockets.target.wants/ 2>&1
ls -l $M/etc/systemd/system/sysinit.target.wants/ 2>&1
echo '=== NM conf.d ==='
ls -l $M/etc/NetworkManager/conf.d/ 2>&1; grep -r . $M/etc/NetworkManager/conf.d/ 2>/dev/null
echo '=== dnsmasq present ==='
ls -l $M/usr/sbin/dnsmasq $M/usr/sbin/udhcpd $M/sbin/udhcpd 2>&1
echo '=== NM connections ==='
ls -l $M/etc/NetworkManager/system-connections/ 2>&1
echo '=== existing gadget.conf ==='
cat $M/etc/modules-load.d/gadget.conf
echo '=== sysinit wants listing ==='
ls -l $M/etc/systemd/system/sysinit.target.wants/ 2>&1
echo '=== qemu binfmt ==='
ls /proc/sys/fs/binfmt_misc/ 2>&1 | head
