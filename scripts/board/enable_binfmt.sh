#!/usr/bin/env bash
set -u
echo "=== before ==="
ls /proc/sys/fs/binfmt_misc/ 2>/dev/null | head
update-binfmts --enable qemu-aarch64 2>&1 || true
systemctl restart systemd-binfmt 2>/dev/null || true
echo "=== after ==="
update-binfmts --display qemu-aarch64 2>&1 | head -8
echo "=== kernel binfmt entries ==="
ls /proc/sys/fs/binfmt_misc/ 2>/dev/null
echo "=== arm64 exec test ==="
cp /usr/bin/qemu-aarch64-static /tmp/qemu-aarch64-static
if [ -x /home/akar/cubie-a5e-fw/rootfs/usr/bin/qemu-aarch64-static ]; then echo rootfs-qemu-present; fi
echo ok
