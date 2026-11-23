#!/bin/sh
# Install cubie-ota into a rootfs.
#
# Run as root inside the target rootfs, or via chroot:
#   chroot /path/to/rootfs /bin/sh /path/to/install.sh
#
# Safe to re-run: units are relinked, existing state.json is never replaced and
# an already seeded /boot/ota/<version> is left untouched.
#
# Chroot safe: no command here requires a running systemd. Units are enabled by
# creating the .wants symlinks directly; systemctl is only used when systemd is
# actually up, and its failure never aborts the install.
#
# This script writes no kernel command line, so it touches no root= / PARTUUID:
# the boot entry stays owned by extlinux and by cubie-ota itself.
set -eu

here=$(cd "$(dirname "$0")" && pwd)
say() { printf 'cubie-ota install: %s\n' "$*"; }

units='cubie-ota-boot.service cubie-ota-confirm.service cubie-ota-confirm.timer'
files="cubie-ota cubie-ota.conf 99cubie-ota $units"

for f in $files; do
    if [ ! -f "$here/$f" ]; then
        echo "cubie-ota install: missing $here/$f" >&2
        exit 1
    fi
done

install -d -m 755 /etc/apt/apt.conf.d /etc/systemd/system /var/lib/cubie-ota
install -d -m 755 /boot /boot/ota

install -m 755 "$here/cubie-ota"                  /usr/bin/cubie-ota
install -m 644 "$here/cubie-ota.conf"             /etc/cubie-ota.conf
install -m 644 "$here/99cubie-ota"                /etc/apt/apt.conf.d/99cubie-ota
install -m 644 "$here/cubie-ota-boot.service"     /etc/systemd/system/cubie-ota-boot.service
install -m 644 "$here/cubie-ota-confirm.service"  /etc/systemd/system/cubie-ota-confirm.service
install -m 644 "$here/cubie-ota-confirm.timer"    /etc/systemd/system/cubie-ota-confirm.timer
say "installed /usr/bin/cubie-ota, /etc/cubie-ota.conf, 99cubie-ota and 3 units"

# ---------------------------------------------------------------- release file
release_file=/etc/cubie-a5e-release
if [ ! -f "$release_file" ]; then
    printf 'VERSION=1.0.0\n' > "$release_file"
    say "created $release_file (VERSION=1.0.0)"
fi
ver=$(sed -n 's/^VERSION=//p' "$release_file" | head -n 1)
if [ -z "$ver" ]; then
    ver=0.0.0
    say "warning: $release_file has no VERSION= line, using $ver"
fi

# ----------------------------------------------------------------- slot seeding
image=/boot/Image
dtb=/boot/dtb/sun55i-a527-cubie-a5e.dtb
slot=/boot/ota/$ver

if [ -d "$slot" ]; then
    say "slot $slot already present, left untouched"
elif [ ! -f "$image" ] || [ ! -f "$dtb" ]; then
    say "not seeding $slot: need $image and $dtb (stage the kernel first, then re-run)"
else
    tmp=$slot.tmp.$$
    trap 'rm -rf "$tmp"' EXIT HUP INT TERM
    rm -rf "$tmp"
    mkdir -p "$tmp"
    cp -a "$image" "$tmp/Image"
    cp -a "$dtb" "$tmp/sun55i-a527-cubie-a5e.dtb"
    say "copied $image and $dtb"

    moddir=$(ls -1 /lib/modules 2>/dev/null | head -n 1 || true)
    if [ -n "$moddir" ] && [ -d "/lib/modules/$moddir" ]; then
        if tar --zstd -cf "$tmp/modules.tar.zst" -C / "lib/modules/$moddir" 2>/dev/null; then
            say "archived /lib/modules/$moddir"
        else
            rm -f "$tmp/modules.tar.zst"
            say "warning: could not archive /lib/modules/$moddir (tar --zstd support missing?)"
        fi
    else
        say "warning: /lib/modules is empty, slot has no modules archive"
    fi

    mv "$tmp" "$slot"
    trap - EXIT HUP INT TERM
    say "seeded $slot from the current firmware (rollback target for the first OTA)"
fi

# ------------------------------------------------------------------------ state
state=/var/lib/cubie-ota/state.json
if [ -f "$state" ]; then
    say "state $state already exists, left untouched"
else
    cat > "$state" <<EOF
{
  "attempts": 0,
  "pending": false,
  "pending_version": null,
  "previous": null,
  "slot": "$ver",
  "version": "$ver"
}
EOF
    say "created $state (slot $ver)"
fi

# --------------------------------------------------------------------- enabling
# Direct symlinks so this works in a chroot with no PID 1 to talk to, and so a
# re-run cannot produce a duplicate or dangling link.
link_unit() {
    unit=$1
    target=$2
    dir=/etc/systemd/system/$target.wants
    mkdir -p "$dir"
    ln -sfn "/etc/systemd/system/$unit" "$dir/$unit"
    say "enabled $unit -> $target"
}

link_unit cubie-ota-boot.service sysinit.target
link_unit cubie-ota-confirm.timer timers.target
# cubie-ota-confirm.service is deliberately not enabled; the timer triggers it.

if [ -d /run/systemd/system ] && command -v systemctl >/dev/null 2>&1; then
    systemctl daemon-reload || say "warning: systemctl daemon-reload failed"
    if systemctl start cubie-ota-confirm.timer; then
        say "started cubie-ota-confirm.timer in the running system"
    else
        say "warning: could not start cubie-ota-confirm.timer now, it starts on next boot"
    fi
else
    say "no running systemd here, daemon-reload skipped (chroot install)"
fi

say "done. next boot runs 'cubie-ota boot-guard'; 'cubie-ota confirm' fires ~90 s after boot."
