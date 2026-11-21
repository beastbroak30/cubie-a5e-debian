#!/usr/bin/env bash
set -uo pipefail
cd /tmp
echo "### linux-aw2607 patches tree"
curl -sL -m 40 https://api.github.com/repos/radxa-pkg/linux-aw2607/contents/debian/patches?ref=main -o pl.json
python3 - <<'PY'
import json
d=json.load(open('/tmp/pl.json'))
for x in d if isinstance(d,list) else []: print(x['type'], x['name'])
PY
echo
echo "### series"
curl -sL -m 40 https://raw.githubusercontent.com/radxa-pkg/linux-aw2607/main/debian/patches/series
echo
echo "### shipped kernel deb dtb entries"
curl -sL -m 240 https://radxa-repo.github.io/a527-trixie-test/pool/main/l/linux-upstream/linux-image-6.6.98-2-aw2607_6.6.98-2_arm64.deb -o kimg.deb
ls -l kimg.deb
dpkg-deb -c kimg.deb | awk '{print $6}' | grep -E 'dtb|Image|config-' | grep -v '^./usr/lib' | sed -n '1,20p'
echo "--- allwinner dtbs dir ---"
dpkg-deb -c kimg.deb | awk '{print $6}' | grep -E 'allwinner/.*\.dtb$' | sed -n '1,5p'
dpkg-deb -c kimg.deb | awk '{print $6}' | grep -cE '\.dtb$'
