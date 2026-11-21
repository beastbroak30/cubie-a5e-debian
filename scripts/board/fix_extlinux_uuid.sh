#!/usr/bin/env bash
set -uo pipefail
IMG=/home/akar/cubie-a5e-fw/output/cubie-a5e-lite-arm64.img
MNT=/tmp/img_mnt
mkdir -p "$MNT"
LOOP=$(losetup -fP --show "$IMG")
mount "${LOOP}p3" "$MNT"

echo "=== Current extlinux.conf ==="
cat "$MNT/boot/extlinux/extlinux.conf"

echo
echo "=== Updating extlinux.conf with UUID ==="
cat << 'EOF' > "$MNT/boot/extlinux/extlinux.conf"
default l0
menu title Radxa Cubie A5E Boot Options
prompt 0
timeout 10

label l0
    menu label Debian GNU/Linux 12 (bookworm) 5.15.147-20-aw2501
    linux /boot/Image
    fdt /boot/dtb/sun55i-a527-cubie-a5e.dtb
    append root=UUID=7cf9f135-82db-4514-af4e-5817cb922fec rw rootwait rootfstype=ext4 earlycon=uart8250,mmio32,0x02500000 console=tty1 console=ttyAS0,115200n8 cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory
EOF

cat "$MNT/boot/extlinux/extlinux.conf"
sync
umount "$MNT"
losetup -d "$LOOP"
echo "=== Fixed ==="
