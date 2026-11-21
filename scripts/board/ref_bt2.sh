#!/bin/bash
set -e
mkdir -p /mnt/refp3
L=$(losetup -fP --show /home/akar/cubie-a5e-fw/cache/ref.img)
trap 'umount /mnt/refp3 2>/dev/null; losetup -d "$L" 2>/dev/null' EXIT
partx -u "$L" 2>/dev/null
mount -o ro "${L}p3" /mnt/refp3
echo '=== rsetup-hciattach@.service ==='
cat /mnt/refp3/lib/systemd/system/rsetup-hciattach@.service
echo '=== rsetup-aic8800-reset@.service ==='
cat /mnt/refp3/lib/systemd/system/rsetup-aic8800-reset@.service
echo '=== /usr/lib/rsetup/mod/aic8800.sh ==='
cat /mnt/refp3/usr/lib/rsetup/mod/aic8800.sh
echo '=== dpkg list: rsetup-config-aic8800-ttyas1 ==='
cat /mnt/refp3/var/lib/dpkg/info/rsetup-config-aic8800-ttyas1.list
echo '=== wants for hciattach ==='
ls /mnt/refp3/etc/systemd/system/*.wants/ 2>/dev/null | head -40
find /mnt/refp3/etc/systemd/system -name '*hciattach*' -o -name '*aic8800*' 2>/dev/null
echo '=== bluetooth.service present? ==='
ls -l /mnt/refp3/lib/systemd/system/bluetooth.service /mnt/refp3/etc/systemd/system/*/bluetooth.service 2>/dev/null
echo '=== bluez installed? ==='
ls /mnt/refp3/var/lib/dpkg/info/bluez.list >/dev/null 2>&1 && echo BLUEZ_YES || echo BLUEZ_NO
