#!/bin/bash
SRC=/home/akar/cubie-a5e-fw/src/linux-aw2501/bsp/drivers/net/wireless/aic8800
echo '=== grep aic8800d80 literal ==='
grep -rn 'aic8800d80' "$SRC" 2>/dev/null | head -20
echo '=== grep firmware path defines ==='
grep -rn 'define.*FW_PATH\|firmware_path\|aicbsp_get_fw\|rwnx_load_firmware' "$SRC" 2>/dev/null | head -20
echo '=== ref mount ==='
mkdir -p /mnt/refp3
L=$(losetup -fP --show /home/akar/cubie-a5e-fw/cache/ref.img)
partx -u "$L" 2>/dev/null
mount -o ro "${L}p3" /mnt/refp3
echo '=== ref aic dirs ==='
find /mnt/refp3/lib/firmware -maxdepth 3 -type d -iname '*aic*' 2>/dev/null
echo '=== ref SDIO fw files ==='
find /mnt/refp3/lib/firmware -path '*aic*' -name '*.bin' | sed 's#/mnt/refp3/lib/firmware/##' | head -40
umount /mnt/refp3
losetup -d "$L"
