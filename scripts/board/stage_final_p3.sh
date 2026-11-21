#!/usr/bin/env bash
set -euo pipefail
ROOTFS=/home/akar/cubie-a5e-fw/rootfs
IMG=/home/akar/cubie-a5e-fw/output/cubie-a5e-lite-arm64.img

MNT=/tmp/img_p3
mkdir -p "$MNT"
LOOP=$(losetup -fP --show "$IMG")
mount "${LOOP}p3" "$MNT"

echo "=== 1. Copying fresh initrd and config to image ==="
cp "$ROOTFS/boot/initrd.img-5.15.147+" "$MNT/boot/initrd.img-5.15.147+"
cp "$ROOTFS/boot/config-5.15.147+" "$MNT/boot/config-5.15.147+"

echo "=== 2. Writing exact verified extlinux.conf ==="
cat << 'EOF' > "$MNT/boot/extlinux/extlinux.conf"
default l0
menu title Radxa Cubie A5E Boot Options
prompt 0
timeout 10

label l0
    menu label Debian GNU/Linux 12 (bookworm) 5.15.147-20-aw2501
    linux /boot/Image
    initrd /boot/initrd.img-5.15.147+
    fdt /boot/dtb/sun55i-a527-cubie-a5e.dtb
    append root=UUID=7cf9f135-82db-4514-af4e-5817cb922fec console=ttyAS0,115200n8 earlyprintk=sunxi-uart,0x2500000 rootwait rw loglevel=7 clk_ignore_unused mac_addr=${mac} mac1_addr=${mac1} coherent_pool=2M irqchip.gicv3_pseudo_nmi=0 cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1 kasan=off
EOF

cat "$MNT/boot/extlinux/extlinux.conf"

echo "=== 3. Exporting updated P3 for Windows direct-flash ==="
sync
dd if="${LOOP}p3" of=/mnt/c/Users/akant/AppData/Local/Temp/opencode/p3_final.bin bs=4M status=progress

umount "$MNT"
losetup -d "$LOOP"
sync
echo "=== Done staging P3! ==="
