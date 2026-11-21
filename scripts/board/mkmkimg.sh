#!/usr/bin/env bash
set -euo pipefail
SIZE=128177930240
IMG=/tmp/card.img
OUT=/mnt/c/Users/akant/AppData/Local/Temp/opencode/card_prefix.bin

rm -f "$IMG" "$OUT"
truncate -s "$SIZE" "$IMG"

# MBR: one primary partition, type 0x07 (exFAT/NTFS), 1 MiB aligned
printf 'label: dos\nstart=2048, type=7, bootable\n' | sfdisk -q "$IMG"

LOOP=$(losetup -fP --show "$IMG")
echo "loop=$LOOP"
lsblk "$LOOP"
mkfs.exfat -n RADXA "${LOOP}p1"
sync
losetup -d "$LOOP"

echo "--- layout ---"
printf 'label: dos\n' | sfdisk -d "$IMG"
echo "--- prefix dump (64 MiB) ---"
dd if="$IMG" of="$OUT" bs=1M count=64 status=none
ls -l "$OUT"
md5sum "$OUT"
