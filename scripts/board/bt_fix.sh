#!/bin/bash
set -x
cat > /usr/local/sbin/aic8800-bt-up.sh <<'EOF'
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
chmod 755 /usr/local/sbin/aic8800-bt-up.sh
cat > /etc/systemd/system/aic8800-bt.service <<'EOF'
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
sed -i 's/^PERCENTAGE=50/PERCENT=50/' /etc/default/zramswap
grep -vE '^#|^$' /etc/default/zramswap
systemctl daemon-reload
systemctl restart aic8800-bt.service 2>&1
systemctl restart zramswap.service 2>&1
sleep 3
systemctl is-active aic8800-bt.service bluetooth.service zramswap.service
cat /proc/swaps
ls /sys/class/bluetooth/
hciconfig -a 2>&1 | head -4
( sleep 2; reboot ) >/dev/null 2>&1 &
echo REBOOT_TRIGGERED
