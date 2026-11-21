#!/bin/bash
set -u
S="sshpass -p radxa ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=15 radxa@10.55.0.1"
R="sshpass -p radxa ssh -t -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null radxa@10.55.0.1"
echo '=== firmware for aic8800 ==='
$R 'ls /lib/firmware | grep -i aic; ls /lib/firmware/aic8800* 2>/dev/null | head; dmesg | grep -i aic | head -20' <<< ''
echo '=== apt update as root ==='
$R "echo radxa | sudo -S apt-get update 2>&1 | tail -4" <<< ''
echo '=== install growpart tooling ==='
$R "echo radxa | sudo -S apt-get install -y cloud-guest-utils 2>&1 | tail -4" <<< ''
echo '=== expand partition 3 ==='
$R "echo radxa | sudo -S growpart /dev/mmcblk0 3 2>&1; echo radxa | sudo -S resize2fs /dev/mmcblk0p3 2>&1 | tail -3; df -h /" <<< ''
echo '=== remove duplicate ifupdown usb0 config ==='
$R "echo radxa | sudo -S rm -f /etc/network/interfaces.d/usb0; echo radxa | sudo -S systemctl daemon-reload; ls /etc/network/interfaces.d/" <<< ''
