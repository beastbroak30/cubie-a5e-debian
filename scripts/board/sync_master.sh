#!/bin/bash
set -euo pipefail
IMG=/home/akar/cubie-a5e-fw/output/cubie-a5e-lite-arm64.img
mkdir -p /mnt/p3m
L=$(losetup -fP --show "$IMG")
cleanup(){ umount /mnt/p3m 2>/dev/null || true; losetup -d "$L" 2>/dev/null || true; }
trap cleanup EXIT
mount "${L}p3" /mnt/p3m
M=/mnt/p3m

# 1. aic8800d80 firmware
mkdir -p "$M/lib/firmware/aic8800d80"
cp -f /mnt/c/Users/akant/AppData/Local/Temp/opencode/aic8800d80/* "$M/lib/firmware/aic8800d80/"
chmod 644 "$M/lib/firmware/aic8800d80/"*
echo "firmware files: $(ls "$M/lib/firmware/aic8800d80" | wc -l)"

# 2. usb0 networkd config with gateway + DNS
cat > "$M/etc/systemd/network/20-usb0.network" <<'EOF'
[Match]
Name=usb0

[Network]
Address=10.55.0.1/24
Gateway=10.55.0.2
DNS=1.1.1.1
DHCPServer=yes
ConfigureWithoutCarrier=yes

[DHCPServer]
PoolOffset=10
PoolSize=20
EmitDNS=no
EOF

# 3. drop duplicate ifupdown config for usb0
rm -f "$M/etc/network/interfaces.d/usb0"

# 4. wifi profile for SSID akar
mkdir -p "$M/etc/NetworkManager/system-connections"
cat > "$M/etc/NetworkManager/system-connections/akar.nmconnection" <<'EOF'
[connection]
id=akar
uuid=1ddd0c50-a919-4da4-b521-d7bfbbe25961
type=wifi
autoconnect=true
autoconnect-priority=10

[wifi]
mode=infrastructure
ssid=akar

[wifi-security]
key-mgmt=wpa-psk
psk=1234567ak

[ipv4]
method=auto

[ipv6]
method=auto
EOF
chmod 600 "$M/etc/NetworkManager/system-connections/akar.nmconnection"

# 5. expand-rootfs: tolerate missing growpart, keep service removable
cat > "$M/usr/local/sbin/expand-rootfs.sh" <<'EOF'
#!/usr/bin/env bash
set -e
ROOT_DEV=$(findmnt -n -o SOURCE /)
DISK="/dev/$(lsblk -no pkname "$ROOT_DEV")"
PART_NUM=$(echo "$ROOT_DEV" | grep -o '[0-9]*$')
if [ -n "$DISK" ] && [ -n "$PART_NUM" ]; then
    echo "Expanding $DISK partition $PART_NUM..."
    if command -v growpart >/dev/null 2>&1; then
        growpart "$DISK" "$PART_NUM" || true
    else
        echo "growpart not installed, skipping partition resize"
    fi
    resize2fs "$ROOT_DEV" || true
fi
systemctl disable expand-rootfs.service || true
rm -f /etc/systemd/system/expand-rootfs.service
EOF
chmod 755 "$M/usr/local/sbin/expand-rootfs.sh"

# 6. install packages in chroot
cp /etc/resolv.conf "$M/etc/resolv.conf"
mkdir -p "$M/dev" "$M/proc" "$M/sys"
for d in dev proc sys; do mount --bind /$d "$M/$d" 2>/dev/null || true; done
export DEBIAN_FRONTEND=noninteractive
chroot "$M" /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get update -qq 2>&1 | tail -3 || true
chroot "$M" /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    systemd-timesyncd cloud-guest-utils iw wireless-tools wpasupplicant 2>&1 | tail -5 || echo APT_INSTALL_ERR
chroot "$M" systemctl enable systemd-timesyncd 2>&1 | tail -2 || true
chroot "$M" systemctl enable aic8800-bsp 2>/dev/null || true
for d in dev proc sys; do umount "$M/$d" 2>/dev/null || true; done

# 7. module autoload for wifi
printf 'aic8800_bsp\naic8800_fdrv\n' > "$M/etc/modules-load.d/aic8800.conf"

echo '=== verify ==='
ls "$M/etc/modules-load.d/"
grep -c . "$M/etc/systemd/network/20-usb0.network"
ls "$M/lib/firmware/aic8800d80" | wc -l
chroot "$M" dpkg -l systemd-timesyncd cloud-guest-utils iw wpasupplicant 2>/dev/null | grep '^ii' | awk '{print $2, $3}'
sync
