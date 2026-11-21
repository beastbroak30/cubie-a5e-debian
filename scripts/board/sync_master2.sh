#!/bin/bash
set -euo pipefail
IMG=/home/akar/cubie-a5e-fw/output/cubie-a5e-lite-arm64.img
mkdir -p /mnt/p3m
L=$(losetup -fP --show "$IMG")
cleanup(){ for d in dev proc sys; do umount /mnt/p3m/$d 2>/dev/null || true; done; umount /mnt/p3m 2>/dev/null || true; losetup -d "$L" 2>/dev/null || true; }
trap cleanup EXIT
mount "${L}p3" /mnt/p3m
M=/mnt/p3m

# zram: Debian zramswap reads PERCENT, not PERCENTAGE
sed -i 's/^PERCENTAGE=/PERCENT=/' "$M/etc/default/zramswap" 2>/dev/null || true
grep -vE '^#|^$' "$M/etc/default/zramswap"

# bluetooth bring-up
cat > "$M/usr/local/sbin/aic8800-bt-up.sh" <<'EOF'
#!/bin/bash
# AIC8800D80 BT: HCI over ttyAS1 at 1500000 8N1 with flow control.
set -u
DEV=/dev/ttyAS1
[ -c "$DEV" ] || { echo "missing $DEV"; exit 1; }
modprobe aic8800_btlpm 2>/dev/null || true
[ -d /sys/class/bluetooth/hci0 ] && { echo "hci0 already present"; exit 0; }
for r in /sys/class/rfkill/rfkill*/; do
    [ -e "$r" ] || continue
    [ "$(cat "$r/type" 2>/dev/null)" = "bluetooth" ] || continue
    echo 0 > "$r/soft" 2>/dev/null || true
done
exec /usr/bin/hciattach -s 1500000 "$DEV" any 1500000 flow nosleep
EOF
chmod 755 "$M/usr/local/sbin/aic8800-bt-up.sh"
cat > "$M/etc/systemd/system/aic8800-bt.service" <<'EOF'
[Unit]
Description=AIC8800D80 Bluetooth (HCI over ttyAS1)
BindsTo=dev-ttyAS1.device
After=dev-ttyAS1.device network.target

[Service]
Type=forking
RemainAfterExit=yes
ExecStart=/usr/local/sbin/aic8800-bt-up.sh

[Install]
WantedBy=multi-user.target
EOF
mkdir -p "$M/etc/systemd/system/multi-user.target.wants"
ln -sf /etc/systemd/system/aic8800-bt.service "$M/etc/systemd/system/multi-user.target.wants/aic8800-bt.service"

# bluez
cp /etc/resolv.conf "$M/etc/resolv.conf"
for d in dev proc sys; do mount --bind /$d "$M/$d"; done
DEBIAN_FRONTEND=noninteractive chroot "$M" apt-get update -qq
DEBIAN_FRONTEND=noninteractive chroot "$M" apt-get install -y -qq bluez 2>&1 | tail -3
chroot "$M" systemctl enable bluetooth.service 2>&1 | tail -2 || true
for d in dev proc sys; do umount "$M/$d"; done

echo '=== verify ==='
ls -l "$M/usr/local/sbin/aic8800-bt-up.sh" "$M/etc/systemd/system/multi-user.target.wants/aic8800-bt.service"
chroot "$M" dpkg -l bluez 2>/dev/null | grep '^ii' | awk '{print $2, $3}'
sync
