#!/usr/bin/env bash
set -uo pipefail
KSRC=/home/akar/cubie-a5e-fw/src/linux-aw2501/src
echo "=== check sun55iw3p1.dtsi mmc node ==="
sed -n '3800,3830p' "$KSRC/arch/arm64/boot/dts/allwinner/sun55iw3p1.dtsi"
