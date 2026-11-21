#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y --no-install-recommends \
  debootstrap qemu-user-static binfmt-support \
  gcc-aarch64-linux-gnu build-essential flex bison libssl-dev libncurses-dev \
  bc kmod cpio rsync device-tree-compiler u-boot-tools \
  parted gdisk dosfstools e2fsprogs \
  xz-utils zstd file sudo nano less \
  crossbuild-essential-arm64 devscripts debhelper dh-exec \
  2>&1 | tail -25
echo "--- versions ---"
debootstrap --version | head -1
aarch64-linux-gnu-gcc --version | head -1
dtc --version
mkimage -V 2>&1 | head -1
update-binfmts --display qemu-aarch64 2>/dev/null | head -5 || echo "binfmt: no entry yet"
