#!/usr/bin/env bash
set -uo pipefail
cd /tmp
get() { echo "----- $1"; curl -sL -m 40 -w '\n[HTTP %{http_code}]\n' "$1"; }
B=https://raw.githubusercontent.com/radxa-pkg/u-boot-dlan17/main
get $B/.gitmodules
get $B/.github/local/Makefile.local
get $B/Makefile.extra
get $B/debian/control
get $B/debian/rules
