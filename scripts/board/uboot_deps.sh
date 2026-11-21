#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get install -y --no-install-recommends \
  python3-setuptools swig python3-dev libgnutls28-dev python3-pyelftools \
  dos2unix gdisk xxd lib32z1 libc6-dev-i386 \
  2>&1 | tail -8
echo "=== done deps ==="
