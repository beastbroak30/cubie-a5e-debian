#!/usr/bin/env bash
cd /home/akar/cubie-a5e-fw/src
echo "########## linux-aw2501 top ##########"
ls linux-aw2501
echo "########## .gitmodules linux ##########"
cat linux-aw2501/.gitmodules 2>/dev/null
echo "########## find kernel Makefile (VERSION) ##########"
for f in $(find linux-aw2501 -maxdepth 3 -name Makefile -path '*linux*' 2>/dev/null | head -10); do
  v=$(grep -m1 -E '^VERSION' "$f" 2>/dev/null); echo "$f :: $v"
done
echo "########## .config locations ##########"
find linux-aw2501 -maxdepth 4 -name .config 2>/dev/null
echo "########## built Image? ##########"
find linux-aw2501 -maxdepth 5 -name 'Image' -o -maxdepth 5 -name 'Image.gz' 2>/dev/null | head
echo "########## u-boot top ##########"
ls u-boot-aw2501
echo "########## .gitmodules u-boot ##########"
cat u-boot-aw2501/.gitmodules 2>/dev/null
echo "########## cubie_a5e board dir ##########"
find u-boot-aw2501 -maxdepth 6 -type d -name 'cubie_a5e' 2>/dev/null
echo "########## defconfigs for a5e/a527 ##########"
find u-boot-aw2501 -maxdepth 6 -name '*a5e*defconfig' -o -maxdepth 6 -name '*a527*defconfig' 2>/dev/null | head -20
echo "########## u-boot source dirs ##########"
find u-boot-aw2501 -maxdepth 3 -name 'u-boot*' -type d 2>/dev/null | head
echo "########## rsdk board config for a5e ##########"
find rsdk -maxdepth 4 -iname '*a5e*' 2>/dev/null | head -20
