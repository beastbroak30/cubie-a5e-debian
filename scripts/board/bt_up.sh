#!/bin/bash
set -x
export DEBIAN_FRONTEND=noninteractive
apt-get install -y -qq bluez 2>&1 | tail -3
command -v bluetoothd hciattach btmon
install -m 755 /tmp/bt_test /usr/local/sbin/bt_test
/usr/local/sbin/bt_test 2>&1 | head -5

cat > /usr/local/sbin/aic8800-bt-up.sh <<'EOF'
#!/bin/bash
# AIC8800D80 BT: reset over ttyAS1, then attach as HCI.
set -u
DEV=/dev/ttyAS1
[ -c "$DEV" ] || { echo "missing $DEV"; exit 1; }
lsmod | grep -q aic8800_fdrv || { echo "aic8800_fdrv not loaded"; exit 1; }
if [ -d /sys/class/bluetooth/hci0 ]; then echo "hci0 already present"; exit 0; fi
out=$(timeout 3 /usr/local/sbin/bt_test -s uart 1500000 "$DEV" 2>&1)
echo "$out"
grep -q 'hci recv thread ready' <<<"$out" || { echo "reset failed"; exit 1; }
exec /usr/bin/hciattach -s 1500000 "$DEV" any 1500000 flow nosleep
EOF
chmod 755 /usr/local/sbin/aic8800-bt-up.sh

cat > /etc/systemd/system/aic8800-bt.service <<'EOF'
[Unit]
Description=AIC8800D80 Bluetooth (HCI over ttyAS1)
After=aic8800-bt-reset-trigger.target network.target
BindsTo=dev-ttyAS1.device
After=dev-ttyAS1.device

[Service]
Type=forking
RemainAfterExit=yes
ExecStart=/usr/local/sbin/aic8800-bt-up.sh

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable aic8800-bt.service 2>&1
systemctl start aic8800-bt.service 2>&1
sleep 3
echo '--- result ---'
systemctl status aic8800-bt.service --no-pager -l 2>&1 | tail -15
ls /sys/class/bluetooth/
bluetoothctl list 2>&1 | head -3
hciconfig -a 2>&1 | head -12
