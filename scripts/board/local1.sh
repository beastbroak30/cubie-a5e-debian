#!/usr/bin/env bash
set -uo pipefail
echo "########## u-boot-update rest ##########"
sed -n '90,230p' /tmp/ubmx/usr/sbin/u-boot-update
echo
echo "########## local linux-aw2501 src ##########"
cd /home/akar/cubie-a5e-fw/src/linux-aw2501
grep -n 'cubie\|a527' src/arch/arm64/boot/dts/allwinner/Makefile || echo "NO DTB ENTRY in src Makefile"
ls -l src/arch/arm64/boot/dts/allwinner/ | grep -i 'a527\|cubie' || echo "no dts file (symlink not created; patch adds only Makefile line)"
echo "-- debian patch line --"
grep -n 'cubie' debian/patches/linux/0004-fix-add-device-tree.patch
echo
echo "########## local u-boot-aw2501 ##########"
cd /home/akar/cubie-a5e-fw/src/u-boot-aw2501
ls -l src/configs/radxa-cubie-a5e_defconfig 2>/dev/null || echo "no a5e defconfig in local src (branch cubie-aiot-v1.4.6)"
grep -n 'CUBIE\|A527' src/configs/*defconfig 2>/dev/null | head -5
grep -rn 'BOOTCOMMAND\|SYSBOOT\|EXTLINUX' src/configs/radxa-cubie-a5e_defconfig 2>/dev/null | head
echo "-- local setup.sh offsets --"
grep -n 'seek=' setup/u-boot_setup-allwinner.sh
