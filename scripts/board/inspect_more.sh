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

mount -o ro "${LOOP}p3" "$MNT"
echo "=== WIRELESS CHIP / FIRMWARE IN ROOTFS ==="
find "$MNT/lib/firmware" -iname "*aic*" -o -iname "*rtl*" -o -iname "*bcm*" -o -iname "*brcm*" -o -iname "*infineon*" -o -iname "*cypress*" -o -iname "*xr*" 2>/dev/null | head -40 || true
echo "=== APT SOURCES IN ROOTFS ==="
cat "$MNT/etc/apt/sources.list" || true
ls -la "$MNT/etc/apt/sources.list.d" || true
cat "$MNT/etc/apt/sources.list.d/"*.list 2>/dev/null || true
umount "$MNT"
