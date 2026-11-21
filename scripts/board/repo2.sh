#!/usr/bin/env bash
set -uo pipefail
echo "=== bookworm README text ==="
curl -sL -m 40 https://radxa-repo.github.io/bookworm/ | sed -e 's/<[^>]*>//g' | grep -v '^[[:space:]]*$' | sed -n '1,80p'
echo
echo "=== trixie Packages: aw2501 / cubie / keyring ==="
curl -sL -m 90 https://radxa-repo.github.io/trixie/dists/trixie/main/binary-arm64/Packages.gz -o /tmp/tx.gz
ls -l /tmp/tx.gz
zcat /tmp/tx.gz | grep -E '^Package: ' | grep -Ei 'aw2501|cubie|a527|keyring|firmware|wireless|aic|rtl' | sort -u
echo
echo "=== keyring filename ==="
zcat /tmp/tx.gz | awk '/^Package: radxa-archive-keyring$/,/^$/' | sed -n '1,20p'
