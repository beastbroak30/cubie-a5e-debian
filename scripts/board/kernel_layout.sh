#!/usr/bin/env bash
cd /home/akar/cubie-a5e-fw/src/linux-aw2501
echo "########## top Makefile ##########"
sed -n '1,60p' Makefile
echo "########## Makefile.extra (head 80) ##########"
sed -n '1,80p' Makefile.extra
echo "########## src/Kconfig bsp include ##########"
grep -n "bsp\|platform" src/Kconfig | head -20
echo "########## bsp/Kconfig head ##########"
sed -n '1,12p' bsp/Kconfig
echo "########## bsp/platform/Kconfig head ##########"
sed -n '1,12p' bsp/platform/Kconfig
echo "########## is bsp symlinked into src? ##########"
ls -ld src/bsp 2>/dev/null || echo "src/bsp MISSING"
echo "########## pkg.conf.template ##########"
cat pkg.conf.template 2>/dev/null
echo "########## debian/rules ##########"
sed -n '1,40p' debian/rules
