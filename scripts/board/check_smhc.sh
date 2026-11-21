#!/usr/bin/env bash
set -uo pipefail
KSRC=/home/akar/cubie-a5e-fw/src/linux-aw2501/src
grep -rn "4022000" "$KSRC/drivers" || true
grep -rn "SMHC" "$KSRC/drivers" | head -10 || true
