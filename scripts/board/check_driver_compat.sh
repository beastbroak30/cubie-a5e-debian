#!/usr/bin/env bash
set -uo pipefail
KSRC=/home/akar/cubie-a5e-fw/src/linux-aw2501/src
echo "=== check driver for sunxi-mmc-v4p6x ==="
grep -rn "sunxi-mmc-v4p6x" "$KSRC/drivers"
echo
echo "=== check driver for sunxi-mmc-v5p3x ==="
grep -rn "sunxi-mmc-v5p3x" "$KSRC/drivers"
