#!/usr/bin/env bash
set -euo pipefail
ROOTFS=/home/akar/cubie-a5e-fw/rootfs
KSRC=/home/akar/cubie-a5e-fw/src/linux-aw2501/src

echo "=== 1. Copying kernel .config to /boot/config-5.15.147+ ==="
cp "$KSRC/.config" "$ROOTFS/boot/config-5.15.147+"

echo "=== 2. Checking compression supported by kernel config ==="
grep -E "CONFIG_RD_" "$KSRC/.config" || true

echo "=== 3. Setting initramfs compression to match kernel ==="
# Check /etc/initramfs-tools/initramfs.conf
sed -i 's/COMPRESS=zstd/COMPRESS=gzip/g' "$ROOTFS/etc/initramfs-tools/initramfs.conf"

echo "=== 4. Re-running update-initramfs ==="
mount -t proc /proc "$ROOTFS/proc" 2>/dev/null || true
mount -t sysfs /sys "$ROOTFS/sys" 2>/dev/null || true
mount --bind /dev "$ROOTFS/dev" 2>/dev/null || true
mount --bind /dev/pts "$ROOTFS/dev/pts" 2>/dev/null || true

chroot "$ROOTFS" update-initramfs -c -k 5.15.147+

umount "$ROOTFS/dev/pts" 2>/dev/null || true
umount "$ROOTFS/dev" 2>/dev/null || true
umount "$ROOTFS/sys" 2>/dev/null || true
umount "$ROOTFS/proc" 2>/dev/null || true

ls -lh "$ROOTFS/boot/initrd.img-5.15.147+"
