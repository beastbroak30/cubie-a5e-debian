#!/usr/bin/env bash
set -uo pipefail
KSRC=/home/akar/cubie-a5e-fw/src/linux-aw2501/src
echo "=== check what driver handles mmc in dts ==="
grep -rn "compatible.*mmc" "$KSRC/arch/arm64/boot/dts/allwinner"
echo
echo "=== check mmc nodes in sun55i-a527 ==="
grep -rn "mmc" "$KSRC/arch/arm64/boot/dts/allwinner/sun55i-a527"*
