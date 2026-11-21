#!/bin/bash
cd /home/akar/cubie-a5e-fw
echo '=== output dir ==='
ls -l output/
echo '=== sfdisk master ==='
sfdisk -d output/cubie-a5e-lite-arm64.img 2>&1 | head
echo '=== stage script ==='
ls -l /mnt/c/Users/akant/AppData/Local/Temp/opencode/ | head -40
echo '=== which debugfs ==='
command -v debugfs e2ls dumpe2fs
echo '=== debugfs test on master p3 ==='
L=$(losetup -fP --show output/cubie-a5e-lite-arm64.img); echo "LOOP=$L"; losetup -d "$L" 2>/dev/null
