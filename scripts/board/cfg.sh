#!/usr/bin/env bash
set -uo pipefail
cd /tmp
echo "=== config.yaml (trixie cli t10) ==="
curl -sL -m 60 https://github.com/radxa-build/radxa-cubie-a5e/releases/download/rsdk-t10/radxa-cubie-a5e_trixie_cli_t10.config.yaml -o a5e.yaml
wc -l a5e.yaml
sed -n '1,200p' a5e.yaml
