#!/usr/bin/env bash
cd /home/akar/cubie-a5e-fw/src/u-boot-aw2501
echo "########## README ##########"
sed -n '1,120p' README.md
echo "########## Makefile ##########"
sed -n '1,80p' Makefile
echo "########## Makefile.extra ##########"
sed -n '1,80p' Makefile.extra
echo "########## debian/rules ##########"
cat debian/rules
echo "########## debian/*.install ##########"
for f in debian/*.install; do echo "== $f"; cat "$f"; done
echo "########## board dir cubie_a5e ##########"
find device-a527/configs/cubie_a5e -maxdepth 2 | head -40
echo "########## setup dir ##########"
ls setup | head -20
echo "########## awbs ##########"
ls awbs 2>/dev/null | head -20
