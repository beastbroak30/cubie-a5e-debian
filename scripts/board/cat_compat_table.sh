#!/usr/bin/env bash
set -uo pipefail
KSRC=/home/akar/cubie-a5e-fw/src/linux-aw2501/src
grep -n "of_device_id" -A 30 "$KSRC/drivers/mmc/host/sunxi-mmc.c"
