#!/bin/bash
echo '=== board: modules for wifi ==='
ssh -i /c/Users/akant/.ssh/cubie_a5e -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null radxa@10.55.0.1 'ls /lib/modules/5.15.147+/kernel/drivers/net/wireless/ 2>/dev/null; echo ---; find /lib/modules/5.15.147+ -iname "*8852*" | head; echo ---FW---; ls /lib/firmware | grep -iE "rtw|8852|rtl" | head -20; echo ---; find /lib/firmware -iname "*8852*" | head' 2>&1
echo '=== ref image: firmware + modules ==='
mkdir -p /mnt/refp3
L=$(losetup -fP --show /home/akar/cubie-a5e-fw/cache/ref.img)
trap 'umount /mnt/refp3 2>/dev/null; losetup -d "$L" 2>/dev/null' EXIT
partx -u "$L" 2>/dev/null
lsblk -o NAME,SIZE "$L" | head
mount -o ro "${L}p3" /mnt/refp3 2>/dev/null || mount -o ro "${L}p2" /mnt/refp3 2>/dev/null || echo REF_MOUNT_FAIL
ls /mnt/refp3 2>/dev/null | head
echo '--- ref firmware ---'
ls /mnt/refp3/lib/firmware 2>/dev/null | grep -iE 'rtw|8852' | head -20
echo '--- ref modules 8852 ---'
find /mnt/refp3/lib/modules -iname '*8852*' 2>/dev/null | head -10
