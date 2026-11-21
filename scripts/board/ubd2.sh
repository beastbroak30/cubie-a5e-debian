#!/usr/bin/env bash
set -uo pipefail
cd /tmp
get() { echo "----- $1"; curl -sL -m 40 -w '\n[HTTP %{http_code}]\n' "$1"; }
echo "### u-boot-dlan17 defconfig"
curl -sL -m 40 https://raw.githubusercontent.com/radxa/u-boot/u-boot-dlan17/configs/radxa-cubie-a5e_defconfig -o ubd_defconfig
wc -l ubd_defconfig
grep -nE 'DEFAULT_DEVICE_TREE|DISTRO_DEFAULTS|BOOTCOMMAND|BOOTDELAY|EXTLINUX|CMD_PART|ENV_|SYS_LOAD|AUTOBOOT' ubd_defconfig | sed -n '1,40p'

echo
echo "### linux-aw2607 packaging"
B=https://raw.githubusercontent.com/radxa-pkg/linux-aw2607/main
get $B/.gitmodules
get $B/.github/local/Makefile.local
