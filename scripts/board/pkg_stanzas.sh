#!/usr/bin/env bash
set -uo pipefail
zcat /tmp/tx.gz > /tmp/tx.txt
echo "=== u-boot / linux-image in trixie main ==="
grep -E '^Package: ' /tmp/tx.txt | grep -Ei 'u-boot|linux-image|linux-headers' | sort -u
echo
echo "=== task-radxa-cubie-a5e stanza ==="
awk '/^Package: task-radxa-cubie-a5e$/,/^$/' /tmp/tx.txt
echo "=== aic8800-firmware stanza ==="
awk '/^Package: aic8800-firmware$/,/^$/' /tmp/tx.txt
echo "=== aic8800-sdio-dkms stanza ==="
awk '/^Package: aic8800-sdio-dkms$/,/^$/' /tmp/tx.txt
echo "=== aic8800-usb-dkms stanza ==="
awk '/^Package: aic8800-usb-dkms$/,/^$/' /tmp/tx.txt
echo "=== radxa-system-config-aic8800-sdio-dkms stanza ==="
awk '/^Package: radxa-system-config-aic8800-sdio-dkms$/,/^$/' /tmp/tx.txt
