#!/usr/bin/env bash
cd /home/akar/cubie-a5e-fw
echo "########## 1x-inspect.log ##########"
tail -40 logs/1x-inspect.log
echo "########## 1x-kernel-build.log tail ##########"
tail -30 logs/1x-kernel-build.log
echo "########## 1x-kernel-build.log head ##########"
head -25 logs/1x-kernel-build.log
echo "########## 1x-uboot-submodules.log ##########"
tail -15 logs/1x-uboot-submodules.log
echo "########## 20-debootstrap.log tail ##########"
tail -15 logs/20-debootstrap.log
echo "########## rootfs pkg count ##########"
chroot rootfs dpkg -l 2>/dev/null | grep -c '^ii' || echo "chroot dpkg failed"
echo "########## rootfs kernel/modules ##########"
ls rootfs/boot 2>/dev/null
ls rootfs/lib/modules 2>/dev/null
echo "########## scripts content: 21 ##########"
sed -n '1,40p' scripts/21-rootfs-config.sh 2>/dev/null
