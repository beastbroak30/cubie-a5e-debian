#!/bin/bash
set -e
mkdir -p /mnt/refp3
L=$(losetup -fP --show /home/akar/cubie-a5e-fw/cache/ref.img)
trap 'umount /mnt/refp3 2>/dev/null; losetup -d "$L" 2>/dev/null' EXIT
partx -u "$L" 2>/dev/null
mount -o ro "${L}p3" /mnt/refp3
echo '=== ref: bt related files in /usr/local or /etc ==='
find /mnt/refp3/etc /mnt/refp3/usr/local /mnt/refp3/usr/bin /mnt/refp3/usr/sbin -iname '*bt*' -maxdepth 3 2>/dev/null | grep -viE 'apt|cups|systemd|dbus|python|perl|ssl|debian' | head -30
echo '=== ref: aic bt scripts ==='
find /mnt/refp3 -maxdepth 6 -iname '*aic*' -not -path '*/firmware/*' 2>/dev/null | head -30
echo '=== ref: systemd units mentioning aic/bt ==='
grep -rl 'aic\|btlpm\|hciattach' /mnt/refp3/etc/systemd /mnt/refp3/lib/systemd 2>/dev/null | head -10
echo '=== ref: bluetooth service state ==='
ls /mnt/refp3/etc/systemd/system/multi-user.target.wants/ 2>/dev/null | head -30
echo '=== ref: modules-load ==='
cat /mnt/refp3/etc/modules-load.d/*.conf 2>/dev/null | head -20
echo '=== ref: zramswap ==='
cat /mnt/refp3/etc/default/zramswap 2>/dev/null | grep -vE '^#|^$'
echo '=== host: zramswap script sizing logic ==='
