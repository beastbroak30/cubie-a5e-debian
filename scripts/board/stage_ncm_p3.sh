#!/bin/bash
set -euo pipefail
IMG=/home/akar/cubie-a5e-fw/output/cubie-a5e-lite-arm64.img
OUT=/mnt/c/Users/akant/AppData/Local/Temp/opencode/p3_ncm.bin
mkdir -p /mnt/p3m
L=$(losetup -fP --show "$IMG")
cleanup() { umount /mnt/p3m 2>/dev/null || true; losetup -d "$L" 2>/dev/null || true; }
trap cleanup EXIT
mount "${L}p3" /mnt/p3m
M=/mnt/p3m

# 1. drop legacy g_ether autoload (module is not built; configfs script handles gadget)
rm -f "$M/etc/modules-load.d/gadget.conf"

# 2. make sure systemd-networkd is enabled (owns usb0 + DHCP server)
mkdir -p "$M/etc/systemd/system/multi-user.target.wants"
ln -sfn /lib/systemd/system/systemd-networkd.service \
        "$M/etc/systemd/system/multi-user.target.wants/systemd-networkd.service"
ln -sfn /lib/systemd/system/systemd-networkd.socket \
        "$M/etc/systemd/system/sockets.target.wants/systemd-networkd.socket"
ln -sfn /lib/systemd/system/systemd-networkd-wait-online.service \
        "$M/etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service"

# 3. gadget script already NCM+ACM; confirm it is executable and service enabled
chmod 0755 "$M/usr/local/sbin/usb-gadget-init.sh"
ln -sfn /etc/systemd/system/usb-gadget.service \
        "$M/etc/systemd/system/sysinit.target.wants/usb-gadget.service"

echo '=== verify ==='
grep -c ncm.usb0 "$M/usr/local/sbin/usb-gadget-init.sh"
cat "$M/etc/systemd/network/20-usb0.network"
ls -l "$M/etc/systemd/system/sysinit.target.wants/"
ls -l "$M/etc/systemd/system/getty.target.wants/"

sync
umount /mnt/p3m
losetup -d "$L"
trap - EXIT

echo '=== dump p3 -> windows ==='
dd if="$IMG" of="$OUT" bs=512 skip=679936 count=7708639 status=progress conv=fsync
echo '=== result ==='
ls -l "$OUT"
sha256sum "$OUT"
