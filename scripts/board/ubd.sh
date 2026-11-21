#!/usr/bin/env bash
set -uo pipefail
cd /tmp
rm -rf ubd && mkdir -p ubd
echo "=== u-boot-dlan17 deb ==="
curl -sL -m 120 https://radxa-repo.github.io/a527-trixie-test/pool/main/u/u-boot-dlan17/u-boot-dlan17_2026.04-5_all.deb -o ubd.deb
ls -l ubd.deb
dpkg-deb -c ubd.deb | awk '{print $6, $3}' | sed -n '1,40p'
dpkg-deb -x ubd.deb ubd
echo
echo "=== radxa-cubie-a5e dir ==="
ls -la ubd/usr/lib/u-boot/radxa-cubie-a5e/ 2>/dev/null
echo
echo "=== setup.sh (shipping) ==="
cat -n ubd/usr/lib/u-boot/radxa-cubie-a5e/setup.sh 2>/dev/null | sed -n '1,120p'
