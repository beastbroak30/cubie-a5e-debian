#!/bin/bash
set -uo pipefail
cd /home/akar/cubie-a5e-fw/output
STAMP=2026-11-21
mkdir -p backups
IMG=cubie-a5e-lite-arm64.img
OUT=backups/cubie-a5e-lite-arm64-$STAMP.img.gz

echo '=== sha256 of source image ==='
sha256sum "$IMG" | tee "$IMG.sha256.tmp"
mv "$IMG.sha256.tmp" "$IMG.sha256"

echo '=== compressing (gzip -1) ==='
time gzip -1 -c "$IMG" > "$OUT"
ls -lh "$OUT"

echo '=== gzip integrity ==='
gzip -t "$OUT" && echo GZIP_OK

echo '=== sha256 of archive ==='
sha256sum "$OUT" | tee "$OUT.sha256"

echo '=== raw copy for local restore (sparse) ==='
cp --sparse=always "$IMG" "backups/cubie-a5e-lite-arm64-$STAMP.img"
ls -lh backups/
sha256sum "backups/cubie-a5e-lite-arm64-$STAMP.img" | tee "backups/cubie-a5e-lite-arm64-$STAMP.img.sha256"
echo DONE
