#!/bin/bash
CFG=/home/akar/cubie-a5e-fw/rootfs/boot/config-5.15.147+
echo '=== wifi config ==='
grep -E 'CONFIG_(RTL8852BS|RTW89|RTW88|AIC8800|AICWF|RTL8XXXU|WL_|WLAN)' "$CFG" | head -40
echo '=== module files present in staged modules ==='
find /home/akar/cubie-a5e-fw/boot/modules -iname '*8852*' -o -iname '*aic*' 2>/dev/null | head -20
echo '=== bsp driver Kconfig/makefile for 8852bs ==='
ls /home/akar/cubie-a5e-fw/src/linux-aw2501/bsp/drivers/net/wireless/rtl8852bs/ | head
grep -rn 'CONFIG_RTL8852BS' /home/akar/cubie-a5e-fw/src/linux-aw2501/bsp/drivers/net/wireless/rtl8852bs/Makefile 2>/dev/null | head
echo '=== built .ko in tree ==='
find /home/akar/cubie-a5e-fw/src/linux-aw2501 -name '*.ko' | grep -iE '8852|aic' | head -20
