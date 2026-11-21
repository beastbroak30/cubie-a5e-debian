#!/usr/bin/env bash
set -uo pipefail
REF=/home/akar/cubie-a5e-fw/cache/ref.img
IMG=/home/akar/cubie-a5e-fw/output/cubie-a5e-lite-arm64.img

MNT_REF=/tmp/deep_ref
MNT_IMG=/tmp/deep_img
mkdir -p "$MNT_REF" "$MNT_IMG"

L_REF=$(losetup -fP --show -o 348127232 "$REF")
L_IMG=$(losetup -fP --show "$IMG")

mount -o ro "$L_REF" "$MNT_REF"
mount -o ro "${L_IMG}p3" "$MNT_IMG"

echo "================ [1] KERNEL CMDLINE IN REF ================"
cat "$MNT_REF/boot/extlinux/extlinux.conf" | grep -E "linux|initrd|fdt|append"

echo
echo "================ [2] INITRD / MODULE AUDIT ================"
echo "Does ref image have initrd?"
ls -lh "$MNT_REF/boot/initrd"* || true

echo "Is MMC/eMMC driver built-in or module in our kernel?"
grep -E "CONFIG_MMC=" /home/akar/cubie-a5e-fw/src/linux-aw2501/src/.config || true
grep -E "CONFIG_MMC_SUNXI" /home/akar/cubie-a5e-fw/src/linux-aw2501/src/.config || true
grep -E "CONFIG_MMC_BLOCK=" /home/akar/cubie-a5e-fw/src/linux-aw2501/src/.config || true
grep -E "CONFIG_MMC_SUNXI_V4P1X=" /home/akar/cubie-a5e-fw/src/linux-aw2501/src/.config || true
grep -E "CONFIG_MMC_SUNXI_V4P5X=" /home/akar/cubie-a5e-fw/src/linux-aw2501/src/.config || true
grep -rn "sunxi-mmc" /home/akar/cubie-a5e-fw/src/linux-aw2501/src/.config || true

echo
echo "================ [3] ROOTFS UUID & PARTUUID CHECK ================"
echo "Reference image partition UUID:"
blkid "$L_REF"
echo "Our image partition UUID:"
blkid "${L_IMG}p3"
echo "Our image disk GPT:"
fdisk -l "$IMG" | grep -A 5 "Device"

echo
echo "================ [4] DTB EXACT MATCH AUDIT ================"
ls -lh "$MNT_REF/usr/lib/linux-image-5.15.147-20-aw2501/allwinner/sun55i-a527-cubie-a5e.dtb"
ls -lh "$MNT_IMG/boot/dtb/sun55i-a527-cubie-a5e.dtb"
cmp "$MNT_REF/usr/lib/linux-image-5.15.147-20-aw2501/allwinner/sun55i-a527-cubie-a5e.dtb" "$MNT_IMG/boot/dtb/sun55i-a527-cubie-a5e.dtb" && echo "DTB is 100% IDENTICAL" || echo "DTB DIFFERS"

echo
echo "================ [5] KERNEL BINARY AUDIT ================"
ls -lh "$MNT_REF/boot/vmlinuz-5.15.147-20-aw2501"
ls -lh "$MNT_IMG/boot/Image"
file "$MNT_REF/boot/vmlinuz-5.15.147-20-aw2501"
file "$MNT_IMG/boot/Image"

echo
echo "================ [6] USB GADGET SERVICE & SCRIPT AUDIT ================"
cat "$MNT_IMG/etc/systemd/system/usb-gadget.service"
echo "--- Script permissions & syntax check ---"
ls -la "$MNT_IMG/usr/local/sbin/usb-gadget-init.sh"
bash -n "$MNT_IMG/usr/local/sbin/usb-gadget-init.sh" && echo "Script syntax OK" || echo "Script syntax ERROR"

umount "$MNT_REF" "$MNT_IMG"
losetup -d "$L_REF" "$L_IMG"
