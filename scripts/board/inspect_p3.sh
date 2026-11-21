#!/bin/bash
IMG=/mnt/c/Users/akant/AppData/Local/Temp/opencode/p3_final.bin
L=$(losetup -fP --show "$IMG" 2>/dev/null)
echo "LOOP=$L"
cleanup() { losetup -d "$L" 2>/dev/null; }
trap cleanup EXIT
DBG="debugfs -R"
echo '=== /etc/modules-load.d ==='
debugfs -R "ls -l /etc/modules-load.d" "$L" 2>/dev/null
echo '=== gadget.conf ==='
debugfs -R "cat /etc/modules-load.d/gadget.conf" "$L" 2>/dev/null
echo '=== /usr/local/sbin ==='
debugfs -R "ls -l /usr/local/sbin" "$L" 2>/dev/null
echo '=== usb-gadget-init.sh (first 80 lines) ==='
debugfs -R "cat /usr/local/sbin/usb-gadget-init.sh" "$L" 2>/dev/null | head -80
echo '=== /etc/systemd/system (names) ==='
debugfs -R "ls /etc/systemd/system" "$L" 2>/dev/null
echo '=== getty.target.wants ==='
debugfs -R "ls -l /etc/systemd/system/getty.target.wants" "$L" 2>/dev/null
echo '=== /boot ==='
debugfs -R "ls -l /boot" "$L" 2>/dev/null
echo '=== extlinux.conf ==='
debugfs -R "cat /boot/extlinux/extlinux.conf" "$L" 2>/dev/null
