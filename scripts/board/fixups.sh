#!/bin/bash
set -euo pipefail
cd /home/akar/cubie-a5e-fw/src/linux-aw2501

ln -sf ../bsp src/bsp
ln -sf cubie_a5e.config src/arch/arm64/configs/bsp.config
ln -sf ../../../../device-a527/configs/cubie_a5e/debian/linux-5.15/bsp_defconfig src/arch/arm64/configs/cubie_a5e.config
ln -sf ../../../../../../device-a527/configs/cubie_a5e/linux-5.15/board.dts src/arch/arm64/boot/dts/allwinner/sun55i-a527-cubie-a5e.dts
cp -aR bsp/configs/linux-5.15/*.dtsi src/arch/arm64/boot/dts/allwinner/
cp -aR bsp/include/dt-bindings/. src/include/dt-bindings/
printf '#define AW_BSP_VERSION "aiot-1.4.6, 2026-11-20, RadxaOS SDK"\n' > bsp/include/sunxi-autogen.h
(cd bsp/ramfs/ramfs_aarch64 && find . | fakeroot cpio -o -Hnewc | gzip > ../ramfs_aarch64.cpio.gz)

echo "FIXUPS_SUCCESS"
