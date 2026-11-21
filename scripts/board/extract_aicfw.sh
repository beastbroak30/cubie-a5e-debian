#!/bin/bash
set -e
mkdir -p /mnt/refp3
L=$(losetup -fP --show /home/akar/cubie-a5e-fw/cache/ref.img)
trap 'umount /mnt/refp3 2>/dev/null; losetup -d "$L" 2>/dev/null' EXIT
partx -u "$L" 2>/dev/null
mount -o ro "${L}p3" /mnt/refp3
S=/mnt/refp3/lib/firmware/aic8800_fw/SDIO/aic8800D80
echo '=== SDIO/aic8800D80 files ==='
ls -l "$S" 2>/dev/null || echo MISSING
DEST=/mnt/c/Users/akant/AppData/Local/Temp/opencode/aic8800d80
rm -rf "$DEST"; mkdir -p "$DEST"
cp -a "$S/." "$DEST"/ 2>/dev/null || true
echo '=== copied ==='
ls -l "$DEST" | head -30
du -sh "$DEST"
