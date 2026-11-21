#!/usr/bin/env bash
set -euo pipefail
ROOTFS=/home/akar/cubie-a5e-fw/rootfs
REF=/home/akar/cubie-a5e-fw/cache/ref.img
IMG=/home/akar/cubie-a5e-fw/output/cubie-a5e-lite-arm64.img

echo "=== 1. Checking kernel version string in rootfs ==="
KVER=$(ls "$ROOTFS/lib/modules")
echo "KVER is: $KVER"

echo "=== 2. Checking if initramfs exists in rootfs ==="
ls -la "$ROOTFS/boot"

echo "=== 3. Generating initramfs inside rootfs using qemu-aarch64 ==="
mount -t proc /proc "$ROOTFS/proc" 2>/dev/null || true
mount -t sysfs /sys "$ROOTFS/sys" 2>/dev/null || true
mount --bind /dev "$ROOTFS/dev" 2>/dev/null || true
mount --bind /dev/pts "$ROOTFS/dev/pts" 2>/dev/null || true

chroot "$ROOTFS" apt-get update || true
chroot "$ROOTFS" apt-get install -y initramfs-tools || true
chroot "$ROOTFS" update-initramfs -c -k "$KVER"

umount "$ROOTFS/dev/pts" 2>/dev/null || true
umount "$ROOTFS/dev" 2>/dev/null || true
umount "$ROOTFS/sys" 2>/dev/null || true
umount "$ROOTFS/proc" 2>/dev/null || true

ls -lh "$ROOTFS/boot/initrd.img-$KVER"
echo "=== initramfs generated successfully ==="
