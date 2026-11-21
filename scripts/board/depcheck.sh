#!/usr/bin/env bash
echo "=== identity/paths ==="
echo "root=/home/akar/cubie-a5e-fw"
ls -d /home/akar/cubie-a5e-fw 2>/dev/null || echo "project root MISSING"
echo "=== tools ==="
for t in debootstrap aarch64-linux-gnu-gcc dtc mkimage parted growpart mkfs.vfat bc bison flex fakeroot debuild; do
  printf '%-24s %s\n' "$t" "$(command -v $t || echo MISSING)"
done
echo "=== binfmt ==="
update-binfmts --display qemu-aarch64 2>/dev/null | head -6 || echo "no qemu-aarch64 binfmt entry"
echo "=== project dirs ==="
du -sh /home/akar/cubie-a5e-fw/* 2>/dev/null
