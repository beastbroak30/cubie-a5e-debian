#!/usr/bin/env bash
set -uo pipefail
REF=/home/akar/cubie-a5e-fw/cache/ref.img
MNT_REF=/tmp/ref_mnt
IMG=/home/akar/cubie-a5e-fw/output/cubie-a5e-lite-arm64.img
MNT_IMG=/tmp/img_mnt
mkdir -p "$MNT_REF" "$MNT_IMG"

L_REF=$(losetup -fP --show -o 348127232 "$REF")
L_IMG=$(losetup -fP --show "$IMG")

mount -o ro "$L_REF" "$MNT_REF"
mount -o ro "${L_IMG}p3" "$MNT_IMG"

echo "=== 1. PARTUUID in our image ==="
blkid "${L_IMG}p3"
blkid "$L_REF"

echo
echo "=== 2. Check /etc/fstab in both ==="
echo "--- Ref fstab ---"
cat "$MNT_REF/etc/fstab"
echo "--- Our fstab ---"
cat "$MNT_IMG/etc/fstab"

echo
echo "=== 3. Check sunxi MMC drivers in kernel config ==="
grep -E "CONFIG_MMC_SUNXI|CONFIG_EXT4_FS|CONFIG_SUNXI_CCU" /home/akar/cubie-a5e-fw/src/linux-aw2501/src/.config || true

umount "$MNT_REF" "$MNT_IMG"
losetup -d "$L_REF" "$L_IMG"
