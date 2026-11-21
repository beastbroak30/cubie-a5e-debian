#!/usr/bin/env bash
set -uo pipefail
cd /tmp
probe() { code=$(curl -sIL -m 25 -o /dev/null -w '%{http_code}' "$1" 2>/dev/null || echo ERR); echo "HEAD $code $1"; }
for u in https://radxa-repo.github.io/a527-trixie/dists/a527-trixie/Release \
         https://radxa-repo.github.io/a527-trixie-test/dists/a527-trixie-test/Release \
         https://radxa-repo.github.io/trixie-test/dists/trixie-test/Release ; do probe "$u"; done
echo
echo "=== .build-512-image ==="
curl -sL -m 60 https://github.com/radxa-build/radxa-cubie-a5e/releases/download/rsdk-t10/radxa-cubie-a5e_trixie_cli_t10.build-512-image -o a5e.build
wc -c a5e.build
cat a5e.build
