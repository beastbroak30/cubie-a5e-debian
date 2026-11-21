#!/usr/bin/env bash
set -uo pipefail
probe() {
  code=$(curl -sIL -m 25 -o /dev/null -w '%{http_code}' "$1" 2>/dev/null || echo ERR)
  echo "HEAD $code $1"
}
for u in \
  https://radxa-repo.github.io/ \
  https://radxa-repo.github.io/bookworm/ \
  https://radxa-repo.github.io/trixie/ \
  https://radxa-repo.github.io/a527-bookworm/ \
  https://radxa-repo.github.io/a527-trixie/ \
  https://radxa-repo.github.io/trixie/dists/trixie/Release \
  https://radxa-repo.github.io/a527-trixie/dists/a527-trixie/Release \
  https://radxa-repo.github.io/radxa-archive-keyring.gpg ; do probe "$u"; done

echo "=== root index ==="
curl -sL -m 25 https://radxa-repo.github.io/ | sed -n '1,80p'
echo "=== bookworm index ==="
curl -sL -m 25 https://radxa-repo.github.io/bookworm/ | sed -n '1,60p'
