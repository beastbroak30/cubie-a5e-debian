#!/bin/bash
set -x
mkdir -p /lib/firmware/aic8800d80
chmod 644 /lib/firmware/aic8800d80/* 2>/dev/null
ls /lib/firmware/aic8800d80 | head
modprobe -r aic8800_fdrv 2>/dev/null
modprobe -r aic8800_bsp 2>/dev/null
sleep 1
modprobe aic8800_bsp
sleep 6
lsmod | grep aic
ip -br link
dmesg 2>/dev/null | tail -40 | grep -iE 'aic|wlan|fw|firmware' 
