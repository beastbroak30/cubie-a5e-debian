#!/bin/bash
set -u
echo '=== reachability from WSL ==='
ping -c 2 -W 2 10.55.0.1 || echo PING_FAIL
if ! command -v sshpass >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq >/dev/null 2>&1 || true
  apt-get install -y -qq sshpass >/dev/null 2>&1 || echo SSHPASS_INSTALL_FAIL
fi
command -v sshpass && sshpass -V | head -1

SSH="sshpass -p radxa ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 radxa@10.55.0.1"
echo '=== whoami / uname ==='
$SSH 'whoami; uname -a; cat /etc/debian_version'
echo '=== root fs ==='
$SSH 'findmnt -no SOURCE,TARGET,FSTYPE /; lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT | head -20'
echo '=== zram / tmp ==='
$SSH 'zramctl; findmnt /tmp; free -h'
echo '=== network ==='
$SSH 'ip -br addr; ip -br link | head -20'
echo '=== services ==='
$SSH 'systemctl --failed --no-pager; systemctl is-active usb-gadget serial-getty@ttyGS0 systemd-networkd ssh'
echo '=== errors ==='
$SSH 'journalctl -b -p err --no-pager | tail -20'
