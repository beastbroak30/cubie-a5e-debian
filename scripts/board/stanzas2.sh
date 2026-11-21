#!/usr/bin/env bash
set -uo pipefail
cd /tmp
echo "=== stanzas (a527-trixie-test) ==="
for p in u-boot-radxa-cubie-a5e u-boot-dlan17 linux-image-radxa-cubie-a5e linux-image-6.6.98-2-aw2607 task-a527; do
  echo "## $p"
  awk -v pkg="$p" 'BEGIN{f=0} $1=="Package:"&&$2==pkg{f=1} f{print} f&&/^$/{exit}' a527t.txt | grep -E '^(Package|Source|Version|Architecture|Depends|Recommends|Filename|Size):'
  echo
done
echo "=== radxa-bootutils in trixie-test ==="
curl -sL -m 90 https://radxa-repo.github.io/trixie-test/dists/trixie-test/main/binary-arm64/Packages.gz -o ttt.gz
zcat ttt.gz > ttt.txt
awk 'BEGIN{f=0} $1=="Package:"&&$2=="radxa-bootutils"{f=1} f{print} f&&/^$/{exit}' ttt.txt | grep -E '^(Package|Version|Filename|Size|Depends):'
echo
echo "=== repo existence via API ==="
for r in radxa-pkg/u-boot-dlan17 radxa-pkg/linux-aw2607 radxa-pkg/linux-aw2501 radxa-pkg/u-boot-aw2501; do
  code=$(curl -s -m 30 -o /tmp/r.json -w '%{http_code}' "https://api.github.com/repos/$r")
  br=$(python3 -c "import json;print(json.load(open('/tmp/r.json')).get('default_branch','-'))" 2>/dev/null || echo -)
  echo "$code $r default_branch=$br"
done
