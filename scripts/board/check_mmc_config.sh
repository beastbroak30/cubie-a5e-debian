#!/usr/bin/env bash
set -uo pipefail
KSRC=/home/akar/cubie-a5e-fw/src/linux-aw2501/src
echo "=== check MMC controller driver symbol in kernel Makefile ==="
grep -rn "sunxi-mmc.o" "$KSRC/drivers/mmc"
echo
echo "=== check what configs enable sunxi MMC ==="
grep -rn "MMC_SUNXI" "$KSRC/drivers/mmc"
