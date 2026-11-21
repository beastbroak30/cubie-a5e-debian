#!/usr/bin/env bash
cd /home/akar/cubie-a5e-fw/src/u-boot-aw2501
echo "########## Makefile.local lines 1-30 ##########"
sed -n '1,30p' .github/local/Makefile.local
echo "########## Makefile.local 180-270 ##########"
sed -n '180,270p' .github/local/Makefile.local
echo "########## device-a527 bin ##########"
ls -l device-a527/bin 2>/dev/null | head -20
echo "########## src u-boot existing config ##########"
ls -l src/.config 2>/dev/null || echo "no src/.config"
echo "########## pack tools ##########"
ls tools/pack/pctools/linux/ 2>/dev/null | head -20
