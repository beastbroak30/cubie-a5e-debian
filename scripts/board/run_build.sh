#!/bin/bash
set -euo pipefail
cd /home/akar/cubie-a5e-fw/src/linux-aw2501/src

export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
export BSP_TOP=bsp/
export CFLAGS="-Wno-enum-int-mismatch"

echo "=== Starting Kernel + DTBS + Modules Build ==="
make -j8 Image dtbs modules 2>&1 | tee /home/akar/cubie-a5e-fw/logs/kernel_build.log

echo "=== Build completed successfully ==="
