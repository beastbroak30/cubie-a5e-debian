#!/usr/bin/env bash
set -euo pipefail

IMG="/home/akar/cubie-a5e-fw/cache/ref.img"
MNT="/tmp/ref_mnt"
mkdir -p "$MNT"

LOOP=$(losetup -fP --show "$IMG")
cleanup() {
    umount "$MNT" 2>/dev/null || true
    losetup -d "$LOOP" 2>/dev/null || true
}
trap cleanup EXIT

echo "=== PARTITION 1 DETAILS ==="
mount -o ro "${LOOP}p1" "$MNT"
echo "--- config.txt ---"
cat "$MNT/config.txt" || true
echo "--- before.txt ---"
cat "$MNT/before.txt" || true
umount "$MNT"

echo "=== PARTITION 3 DETAILS ==="
mount -o ro "${LOOP}p3" "$MNT"
echo "--- /boot/uEnv.txt ---"
cat "$MNT/boot/uEnv.txt" || true
echo "--- /boot/hw_intfc.conf ---"
cat "$MNT/boot/hw_intfc.conf" || true
echo "--- /usr/lib/linux-image* listing ---"
find "$MNT/usr/lib/linux-image-5.15.147-20-aw2501" -ls || true
echo "--- /boot DTBs ---"
ls -la "$MNT"/boot/*.dtb 2>/dev/null || echo "No .dtb in /boot"
echo "--- /usr/lib/modules listing ---"
ls -la "$MNT/usr/lib/modules" 2>/dev/null || true
echo "--- wireless / firmware blobs in /lib/firmware ---"
find "$MNT/lib/firmware" -maxdepth 2 -ls || true
umount "$MNT"
