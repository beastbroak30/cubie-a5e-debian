#!/usr/bin/env bash
set -uo pipefail
REF=/home/akar/cubie-a5e-fw/cache/ref.img
MNT=/tmp/ref_mnt
mkdir -p "$MNT"
LOOP=$(losetup -fP --show -o 348127232 "$REF")
mount -o ro "$LOOP" "$MNT"

echo "=== initrd contents in ref.img ==="
lsinitramfs "$MNT/boot/initrd.img-5.15.147-20-aw2501" | grep -E "ext4|sunxi|mmc|block" | head -30

echo
echo "=== check uEnv.txt and hw_intfc.conf ==="
cat "$MNT/boot/uEnv.txt" || true
echo "---"
cat "$MNT/boot/hw_intfc.conf" || true

umount "$MNT"
losetup -d "$LOOP"
