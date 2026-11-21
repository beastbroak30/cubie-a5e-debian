#!/usr/bin/env bash
set -uo pipefail
dpkg-deb -c /tmp/kimg.deb > /tmp/kimg.list
echo "=== /boot entries ==="
grep -E ' \./boot/' /tmp/kimg.list | awk '{print $3, $6}'
echo "=== all dtb count ==="
grep -c '\.dtb$' /tmp/kimg.list
echo "=== sun55 / a527 / cubie ==="
grep -Ei 'sun55|a527|cubie' /tmp/kimg.list || echo NONE
echo "=== last 6 dtbs ==="
grep '\.dtb$' /tmp/kimg.list | tail -6 | awk '{print $6}'
