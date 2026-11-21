#!/bin/bash
set -x
printf 'aic8800_bsp\naic8800_fdrv\n' > /etc/modules-load.d/aic8800.conf
rm -f /etc/network/interfaces.d/usb0
ls /etc/modules-load.d/
df -h / | tail -1
( sleep 2; reboot ) >/dev/null 2>&1 &
echo REBOOT_TRIGGERED
