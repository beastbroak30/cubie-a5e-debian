#!/usr/bin/env bash
set -uo pipefail
for u in \
  http://apt.radxa.com/ \
  http://apt.radxa.com/bullseye-stable/ \
  http://apt.radxa.com/bookworm-stable/ \
  http://apt.radxa.com/radxa-deb/ \
  https://apt.radxa.com/ \
  https://apt.radxa.com/bullseye-stable/ \
  https://apt.radxa.com/bookworm-stable/ \
  https://apt.radxa.com/radxa-deb/ ; do
  code=$(curl -sIL -m 25 -o /dev/null -w '%{http_code}' "$u" 2>/dev/null || echo ERR)
  echo "HEAD $code $u"
done
echo "=== GET index http://apt.radxa.com/ ==="
curl -sL -m 25 http://apt.radxa.com/ | sed -n '1,120p'
echo "=== GET index https://apt.radxa.com/ ==="
curl -sL -m 25 https://apt.radxa.com/ | sed -n '1,120p'
