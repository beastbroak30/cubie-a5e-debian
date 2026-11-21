#!/usr/bin/env bash
set -uo pipefail
LOG=/home/akar/cubie-a5e-fw/logs/kernel-build-direct.log
exec > >(tee -a "$LOG") 2>&1
echo "=== Direct Kernel Build $(date -Is) ==="

cd /home/akar/cubie-a5e-fw/src/linux-aw2501 || exit 1

echo "--- fixup links ---"
make pre_build -j8 2>&1 | tail -10

cd src || exit 1
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
export BSP_TOP=bsp/
export LICHEE_KERN_DIR=$(pwd)
export KCFLAGS="-Wno-enum-int-mismatch -Wno-error"
export CFLAGS="-Wno-enum-int-mismatch -Wno-error"

echo "--- make -j8 Image dtbs modules ---"
make -j8 Image dtbs modules \
    BSP_TOP=bsp/ \
    LICHEE_KERN_DIR="$(pwd)" \
    KCFLAGS="-Wno-enum-int-mismatch -Wno-error"

RC=$?
echo "make exit: $RC"
if [ $RC -ne 0 ]; then
    echo "BUILD FAILED"
    exit $RC
fi

echo "--- stage Image ---"
mkdir -p /home/akar/cubie-a5e-fw/boot/dtbs
cp -v arch/arm64/boot/Image /home/akar/cubie-a5e-fw/boot/Image
cp -v arch/arm64/boot/dts/allwinner/sun55i-a527-cubie-a5e.dtb /home/akar/cubie-a5e-fw/boot/dtbs/

echo "--- modules_install ---"
make -j8 modules_install \
    INSTALL_MOD_PATH=/home/akar/cubie-a5e-fw/boot/modules \
    BSP_TOP=bsp/ \
    LICHEE_KERN_DIR="$(pwd)"

echo "--- record release ---"
make -s kernelrelease BSP_TOP=bsp/ LICHEE_KERN_DIR="$(pwd)" > /home/akar/cubie-a5e-fw/boot/kernelrelease
cat /home/akar/cubie-a5e-fw/boot/kernelrelease

echo "=== Kernel Build Complete $(date -Is) ==="
exit 0
