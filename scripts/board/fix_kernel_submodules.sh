#!/usr/bin/env bash
set -uo pipefail
cd /home/akar/cubie-a5e-fw/src/linux-aw2501
echo "=== bsp tree ==="
ls bsp | head -20
echo "=== platform dir? ==="
ls -d bsp/platform 2>/dev/null || echo "bsp/platform MISSING"
echo "=== submodule status ==="
git submodule status | head -10
echo "=== bsp git status ==="
cd bsp && git log --oneline -1 2>/dev/null; ls | head
echo "=== try full init ==="
cd /home/akar/cubie-a5e-fw/src/linux-aw2501
timeout 1800 git submodule update --init --recursive 2>&1 | tail -20
echo "=== recheck ==="
ls -d bsp/platform 2>/dev/null || echo "bsp/platform STILL MISSING"
find bsp -maxdepth 2 -name 'Kconfig' | head
