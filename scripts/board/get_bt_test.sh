#!/bin/bash
set -e
mkdir -p /mnt/refp3
L=$(losetup -fP --show /home/akar/cubie-a5e-fw/cache/ref.img)
trap 'umount /mnt/refp3 2>/dev/null; losetup -d "$L" 2>/dev/null' EXIT
partx -u "$L" 2>/dev/null
mount -o ro "${L}p3" /mnt/refp3
cp -f /mnt/refp3/usr/bin/bt_test /mnt/c/Users/akant/AppData/Local/Temp/opencode/bt_test
chmod 755 /mnt/c/Users/akant/AppData/Local/Temp/opencode/bt_test
ls -l /mnt/c/Users/akant/AppData/Local/Temp/opencode/bt_test
