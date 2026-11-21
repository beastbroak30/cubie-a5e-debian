#!/usr/bin/env bash
set -uo pipefail
cd /tmp
echo "### radxa-bootutils"
curl -sL -m 60 https://radxa-repo.github.io/trixie-test/pool/main/r/radxa-bootutils/radxa-bootutils_0.2.6_all.deb -o bu.deb
dpkg-deb -c bu.deb | awk '{print $6}'
rm -rf bux && dpkg-deb -x bu.deb bux
echo "--- files ---"
find bux -type f | while read -r f; do echo "== $f"; sed -n '1,120p' "$f"; done

echo
echo "### rsetup-config-aic8800-ttyas1"
curl -sL -m 60 https://radxa-repo.github.io/trixie/pool/main/r/radxa-profiles/rsetup-config-aic8800-ttyas1_0.4.53_all.deb -o rs.deb 2>/dev/null || true
ls -l rs.deb 2>/dev/null && dpkg-deb -c rs.deb | awk '{print $6}'
