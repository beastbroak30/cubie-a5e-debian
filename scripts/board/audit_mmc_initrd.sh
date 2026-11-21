#!/usr/bin/env bash
set -uo pipefail
REF=/home/akar/cubie-a5e-fw/cache/ref.img
MNT_REF=/tmp/deep_ref
mkdir -p "$MNT_REF"
L_REF=$(losetup -fP --show -o 348127232 "$REF")
mount -o ro "$L_REF" "$MNT_REF"

echo "=== 1. What MMC driver is built in kernel object? ==="
grep -rn "sunxi_mmc" /home/akar/cubie-a5e-fw/src/linux-aw2501/src/drivers/mmc/ 2>/dev/null | head -10 || true
grep -i "sunxi" /home/akar/cubie-a5e-fw/src/linux-aw2501/src/.config | grep -i "mmc" || true

echo
echo "=== 2. Check if initrd is required or what modules are in ref initrd ==="
cp "$MNT_REF/boot/initrd.img-5.15.147-20-aw2501" /tmp/ref_initrd.cpio.gz
cd /tmp
mkdir -p /tmp/initrd_unpacked
cd /tmp/initrd_unpacked
gzip -dc /tmp/ref_initrd.cpio.gz 2>/dev/null | cpio -idmv > /dev/null 2>&1 || true
echo "Modules in ref initrd:"
find lib/modules -name "*.ko*" | sort

echo
echo "=== 3. What is in our /lib/modules? ==="
ls -la /home/akar/cubie-a5e-fw/rootfs/lib/modules/

umount "$MNT_REF"
losetup -d "$L_REF"
