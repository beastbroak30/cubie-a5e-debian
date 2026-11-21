#!/bin/bash
echo '=== firmware blobs in kernel tree ==='
find /home/akar/cubie-a5e-fw/src/linux-aw2501 -iname 'fw_patch_table*' -o -iname '*8800d80*bin' 2>/dev/null | head -20
echo '=== aic fw dirs ==='
find /home/akar/cubie-a5e-fw/src/linux-aw2501 -type d -iname 'fw*' -path '*aic*' 2>/dev/null | head
echo '=== ref image /lib/firmware aic ==='
mkdir -p /mnt/refp3
L=$(losetup -fP --show /home/akar/cubie-a5e-fw/cache/ref.img)
trap 'umount /mnt/refp3 2>/dev/null; losetup -d "$L" 2>/dev/null' EXIT
partx -u "$L" 2>/dev/null
mount -o ro "${L}p3" /mnt/refp3 || { echo MOUNT_FAIL; exit 1; }
ls /mnt/refp3/lib/firmware | head -40
echo '--- aic8800d80 ---'
ls /mnt/refp3/lib/firmware/aic8800d80/ 2>/dev/null || echo NONE
echo '--- aic8800dtbl/aicbsp ---'
find /mnt/refp3/lib/firmware -iname '*8800*' | head -20
