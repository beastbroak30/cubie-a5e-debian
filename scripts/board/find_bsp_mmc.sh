#!/usr/bin/env bash
set -uo pipefail
KSRC=/home/akar/cubie-a5e-fw/src/linux-aw2501/src
grep -rn "bsp/drivers/mmc" "$KSRC"
