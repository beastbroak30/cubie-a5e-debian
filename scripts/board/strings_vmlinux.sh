#!/usr/bin/env bash
set -uo pipefail
KSRC=/home/akar/cubie-a5e-fw/src/linux-aw2501/src
echo "=== search for sunxi-mmc-v4p6x in vmlinux ==="
strings "$KSRC/vmlinux" | grep "sunxi-mmc"
