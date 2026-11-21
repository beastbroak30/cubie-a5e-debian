#!/usr/bin/env bash
set -uo pipefail
IMG=/home/akar/cubie-a5e-fw/output/cubie-a5e-lite-arm64.img
REF=/home/akar/cubie-a5e-fw/cache/ref.img

MNT_IMG=/tmp/check_img
MNT_REF=/tmp/check_ref
mkdir -p "$MNT_IMG" "$MNT_REF"

L_IMG=$(losetup -fP --show "$IMG")
L_REF=$(losetup -fP --show "$REF")

mount -o ro "${L_IMG}p3" "$MNT_IMG"
mount -o ro "${L_REF}p3" "$MNT_REF"

echo "================ 1. REFSYS EXTLINUX ================"
cat "$MNT_REF/boot/extlinux/extlinux.conf"

echo
echo "================ 2. OUR CURRENT EXTLINUX ================"
cat "$MNT_IMG/boot/extlinux/extlinux.conf"

echo
echo "================ 3. REFSYS /boot LISTING ================"
ls -la "$MNT_REF/boot"
find "$MNT_REF/boot" -maxdepth 3

echo
echo "================ 4. OUR /boot LISTING ================"
ls -la "$MNT_IMG/boot"
find "$MNT_IMG/boot" -maxdepth 3

echo
echo "================ 5. DTB SEARCH IN BOTH ================"
echo "--- In ref.img ---"
find "$MNT_REF" -name "*sun55i-a527-cubie-a5e*" 2>/dev/null
echo "--- In our img ---"
find "$MNT_IMG" -name "*sun55i-a527-cubie-a5e*" 2>/dev/null

echo
echo "================ 6. MODULES / INITRD IN REFSYS ================"
ls -la "$MNT_REF/lib/modules"
ls -la "$MNT_IMG/lib/modules"

umount "$MNT_IMG" "$MNT_REF"
losetup -d "$L_IMG" "$L_REF"
