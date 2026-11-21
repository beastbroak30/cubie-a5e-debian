#!/usr/bin/env bash
set -uo pipefail
cd /tmp
probe() { code=$(curl -sIL -m 25 -o /dev/null -w '%{http_code}' "$1" 2>/dev/null || echo ERR); echo "HEAD $code $1"; }
for s in a527-trixie a527-trixie-test a527-bookworm a527-bookworm-test a527-bullseye a527-sid a527-sid-test; do
  probe "https://radxa-repo.github.io/$s/dists/$s/Release"
done
echo
echo "=== a527-trixie-test Packages: relevant pkgs ==="
curl -sL -m 90 https://radxa-repo.github.io/a527-trixie-test/dists/a527-trixie-test/main/binary-arm64/Packages.gz -o a527t.gz
ls -l a527t.gz
zcat a527t.gz > a527t.txt
grep -E '^Package: ' a527t.txt | grep -Ei 'u-boot|linux-image|linux-headers|linux-libc|bootutils|firmware' | sort -u
echo "--- versions ---"
for p in u-boot-radxa-cubie-a5e u-boot-aw2501 linux-image-radxa-cubie-a5e radxa-bootutils; do
  echo "## $p"; awk -v pkg="$p" '$1=="Package:" && $2==pkg {f=1} f&&/^(Version|Filename|Size):/{print} f&&/^$/{if(NR>1)f=0}' a527t.txt | head -6
done
