#!/usr/bin/env bash
set -u
SIZE=128177930240
IMG=/tmp/card.img
rm -f "$IMG"
truncate -s "$SIZE" "$IMG"
printf 'label: dos\nstart=2048, type=7, bootable\n' | sfdisk -q "$IMG"
LOS=$(losetup -fP --show "$IMG")
echo "loop=$LOS"
mkfs.exfat -n RADXA "${LOS}p1" >/dev/null 2>&1
echo "--- fsck ---"
fsck.exfat -n -v "${LOS}p1" 2>&1 | tail -12
echo "--- mount test ---"
mkdir -p /mnt/sdtest
mount -t exfat "${LOS}p1" /mnt/sdtest && { touch /mnt/sdtest/_probe && ls -l /mnt/sdtest && rm /mnt/sdtest/_probe; umount /mnt/sdtest; echo "mount+write OK"; } || echo "mount failed"
losetup -d "$LOS"
rm -f "$IMG"
