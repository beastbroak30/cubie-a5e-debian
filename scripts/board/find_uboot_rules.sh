#!/usr/bin/env bash
cd /home/akar/cubie-a5e-fw/src
echo "########## grep boot0_sdcard rules in u-boot tree ##########"
grep -rn "boot0_sdcard\|boot_package.fex\|update_boot0\|spl-pub" u-boot-aw2501 --include=Makefile* --include=*.mk --include=*.sh --include=*.rules --include=*.local 2>/dev/null | head -40
echo "########## u-boot Makefile.extra uboot products ##########"
grep -rn "UBOOT_PRODUCTS\|out/" u-boot-aw2501/Makefile.extra u-boot-aw2501/debian/rules* u-boot-aw2501/.github 2>/dev/null | head -30
echo "########## u-boot src Makefile targets for a5e ##########"
grep -rn "cubie_a5e\|cubie-a5e" u-boot-aw2501 --include=Makefile* --include=*.mk --include=*.sh 2>/dev/null | head -30
echo "########## rsdk a5e references ##########"
grep -rln "cubie-a5e\|cubie_a5e\|aw2501" rsdk 2>/dev/null | head -30
echo "########## rsdk layout ##########"
ls rsdk
