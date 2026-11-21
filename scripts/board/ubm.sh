#!/usr/bin/env bash
set -uo pipefail
cd /tmp
echo "### u-boot-menu 4.2.4"
curl -sL -m 60 https://deb.debian.org/debian/pool/main/u/u-boot-menu/u-boot-menu_4.2.4_all.deb -o ubm.deb
rm -rf ubmx && dpkg-deb -x ubm.deb ubmx
find ubmx -type f | sed -n '1,20p'
echo "--- /etc/default/u-boot ---"; cat ubmx/etc/default/u-boot 2>/dev/null
echo "--- u-boot-update (first 90) ---"; sed -n '1,90p' ubmx/usr/sbin/u-boot-update 2>/dev/null
echo "--- conf.d snippets ---"; ls -la ubmx/etc/u-boot-menu/conf.d 2>/dev/null; cat ubmx/etc/u-boot-menu/conf.d/* 2>/dev/null | sed -n '1,60p'
echo
echo "### radxa-system-config-kernel-cmdline-ttyas0"
curl -sL -m 60 https://radxa-repo.github.io/trixie/pool/main/r/radxa-system-config/radxa-system-config-kernel-cmdline-ttyas0_0.7.5_all.deb -o rsc.deb
dpkg-deb -c rsc.deb | awk '{print $6}'
rm -rf rscx && dpkg-deb -x rsc.deb rscx
find rscx -type f -not -path '*/doc/*' | while read -r f; do echo "== $f"; cat "$f"; echo; done
