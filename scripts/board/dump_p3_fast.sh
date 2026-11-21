#!/bin/bash
set -euo pipefail
IMG=/home/akar/cubie-a5e-fw/output/cubie-a5e-lite-arm64.img
OUT=/mnt/c/Users/akant/AppData/Local/Temp/opencode/p3_ncm.bin
rm -f "$OUT"
time dd if="$IMG" of="$OUT" bs=1M skip=332 count=3764 conv=fsync
truncate -s 3946823168 "$OUT"
ls -l "$OUT"
sha256sum "$OUT"
