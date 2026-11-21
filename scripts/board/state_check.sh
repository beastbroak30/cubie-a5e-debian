#!/bin/bash
set -uo pipefail
cd /home/akar/cubie-a5e-fw
echo '=== dirs ==='
ls -1
echo '=== scripts ==='
ls -1 scripts/ 2>/dev/null
echo '=== output ==='
ls -lh output/ 2>/dev/null
echo '=== git ==='
command -v git && git --version
git -C . status --porcelain 2>&1 | head -3
echo '=== image info ==='
IMG=output/cubie-a5e-lite-arm64.img
ls -l "$IMG" 2>/dev/null
stat -c '%s %y' "$IMG" 2>/dev/null
echo '=== free space ==='
df -h /home /mnt/c 2>/dev/null | tail -3
echo '=== existing sha ==='
cat output/*.sha256 2>/dev/null | head -5
