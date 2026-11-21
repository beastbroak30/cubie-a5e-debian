#!/usr/bin/env bash
set -euo pipefail

IMG="/home/akar/cubie-a5e-fw/cache/ref.img"
MNT="/tmp/ref_mnt"
mkdir -p "$MNT"

LOOP=$(losetup -fP --show "$IMG")
cleanup() {
    umount "$MNT" 2>/dev/null || true
    losetup -d "$LOOP" 2>/dev/null || true
    echo "CLEANUP_DONE"
}
trap cleanup EXIT

echo "=== LOOP DEVICE ==="
echo "LOOP=$LOOP"

echo "=== LSBLK ==="
lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT,UUID "$LOOP"

echo "=== BLKID ==="
blkid "${LOOP}"*

echo "=== PARTITION 1 INSPECTION ==="
mount -o ro "${LOOP}p1" "$MNT"
echo "p1 content:"
ls -la "$MNT"
umount "$MNT"

echo "=== PARTITION 2 INSPECTION ==="
mount -o ro "${LOOP}p2" "$MNT"
echo "p2 content:"
ls -la "$MNT"
find "$MNT" -maxdepth 4 -ls
if [ -f "$MNT/extlinux/extlinux.conf" ]; then
    echo "--- extlinux/extlinux.conf ---"
    cat "$MNT/extlinux/extlinux.conf"
fi
if [ -f "$MNT/boot.scr" ]; then
    echo "--- mkimage -l boot.scr ---"
    mkimage -l "$MNT/boot.scr" || true
    echo "--- strings boot.scr head 80 ---"
    strings "$MNT/boot.scr" | head -80
fi
umount "$MNT"

echo "=== PARTITION 3 INSPECTION ==="
mount -o ro "${LOOP}p3" "$MNT"
echo "p3 /boot content:"
if [ -d "$MNT/boot" ]; then
    ls -la "$MNT/boot"
    find "$MNT/boot" -maxdepth 3 -ls
    if [ -f "$MNT/boot/extlinux/extlinux.conf" ]; then
        echo "--- /boot/extlinux/extlinux.conf ---"
        cat "$MNT/boot/extlinux/extlinux.conf"
    fi
    if [ -f "$MNT/boot/boot.scr" ]; then
        echo "--- /boot/boot.scr ---"
        mkimage -l "$MNT/boot/boot.scr" || true
        strings "$MNT/boot/boot.scr" | head -80
    fi
else
    echo "No /boot dir in p3!"
fi
echo "p3 /etc/os-release:"
cat "$MNT/etc/os-release" || true
echo "p3 /etc/fstab:"
cat "$MNT/etc/fstab" || true
umount "$MNT"
