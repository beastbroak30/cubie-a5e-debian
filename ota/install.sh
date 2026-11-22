#!/bin/sh
# Install cubie-ota into a rootfs (run as root inside the rootfs or via chroot).
# Also seeds the currently running firmware as slot 1 so the first OTA has a
# rollback target.
set -eu
here=$(dirname "$0")

install -m 755 "$here/cubie-ota"            /usr/bin/cubie-ota
install -m 644 "$here/cubie-ota.conf"       /etc/cubie-ota.conf
install -m 644 "$here/99cubie-ota"          /etc/apt/apt.conf.d/99cubie-ota
install -m 644 "$here/cubie-ota-boot.service"    /etc/systemd/system/cubie-ota-boot.service
install -m 644 "$here/cubie-ota-confirm.service" /etc/systemd/system/cubie-ota-confirm.service
install -m 644 "$here/cubie-ota-confirm.timer"   /etc/systemd/system/cubie-ota-confirm.timer

mkdir -p /boot/ota /var/lib/cubie-ota

[ -f /etc/cubie-a5e-release ] || echo 'VERSION=1.0.0' > /etc/cubie-a5e-release
ver=$(sed -n 's/^VERSION=//p' /etc/cubie-a5e-release)
kver=$(ls /lib/modules | head -1)

if [ ! -d "/boot/ota/$ver" ]; then
    mkdir -p "/boot/ota/$ver"
    cp -a /boot/Image "/boot/ota/$ver/Image"
    cp -a "/boot/dtb/sun55i-a527-cubie-a5e.dtb" "/boot/ota/$ver/sun55i-a527-cubie-a5e.dtb"
    tar --zstd -cf "/boot/ota/$ver/modules.tar.zst" -C / "lib/modules/$kver"
fi

if [ ! -f /var/lib/cubie-ota/state.json ]; then
    cat > /var/lib/cubie-ota/state.json <<EOF
{
  "attempts": 0,
  "pending": false,
  "pending_version": null,
  "previous": null,
  "slot": "$ver",
  "version": "$ver"
}
EOF
fi

systemctl enable cubie-ota-boot.service cubie-ota-confirm.timer
