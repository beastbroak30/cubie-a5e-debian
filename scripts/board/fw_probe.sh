#!/usr/bin/env bash
set -uo pipefail
R=https://radxa-repo.github.io/trixie
cd /tmp
echo "=== board releases API ==="
curl -sL -m 60 "https://api.github.com/repos/radxa-build/radxa-cubie-a5e/releases?per_page=4" -o /tmp/rel.json
python3 - <<'PY'
import json
d=json.load(open('/tmp/rel.json'))
if isinstance(d,dict):
    print('ERR', str(d)[:300]); raise SystemExit
for r in d[:3]:
    print('TAG', r['tag_name'], r['published_at'])
    for a in r['assets']:
        print('   %-70s %10d  %s' % (a['name'], a['size'], a['browser_download_url']))
PY

echo
echo "=== aic8800-firmware file list ==="
curl -sL -m 120 "$R/pool/main/a/aic8800/aic8800-firmware_5.0+git20260123.5f7be68d-11_all.deb" -o aicfw.deb
dpkg-deb -c aicfw.deb | awk '{print $6, $3}' | sed -n '1,80p'
echo
echo "=== kernel cmdline package ==="
zcat /tmp/tx.gz > /tmp/tx.txt
awk '/^Package: radxa-system-config-kernel-cmdline-ttyas0$/,/^$/' /tmp/tx.txt | grep -E '^(Package|Version|Filename|Size):'
