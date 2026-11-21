#!/usr/bin/env bash
set -euo pipefail
cd /home/akar/cubie-a5e-fw/src
for r in u-boot-aw2501 linux-aw2501 rsdk; do
  if [ -d "$r/.git" ]; then echo "== $r exists, skip"; else echo "== clone $r"; fi
done
[ -d u-boot-aw2501/.git ] || git clone --depth 1 https://github.com/radxa-pkg/u-boot-aw2501.git
[ -d linux-aw2501/.git ]   || git clone --depth 1 https://github.com/radxa-pkg/linux-aw2501.git
[ -d rsdk/.git ]           || git clone --depth 1 https://github.com/RadxaOS-SDK/rsdk.git
for r in u-boot-aw2501 linux-aw2501 rsdk; do
  echo "===== $r ====="
  du -sh "$r"
  echo "--- top level ---"
  ls -a "$r" | head -30
  echo "--- .gitmodules ---"
  cat "$r/.gitmodules" 2>/dev/null || echo "(none)"
done
