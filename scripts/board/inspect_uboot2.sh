#!/usr/bin/env bash
cd /home/akar/cubie-a5e-fw/src/u-boot-aw2501
echo "########## pkg.conf.template ##########"
cat pkg.conf.template 2>/dev/null
echo "########## debian/control ##########"
sed -n '1,60p' debian/control
echo "########## setup/u-boot_setup-allwinner.sh ##########"
sed -n '1,80p' setup/u-boot_setup-allwinner.sh
echo "########## awbs/README ##########"
sed -n '1,60p' awbs/README.md 2>/dev/null
echo "########## awbs/awbs ##########"
ls awbs/awbs 2>/dev/null | head -20
echo "########## board BoardConfig.mk (debian variant) ##########"
cat device-a527/configs/cubie_a5e/debian/BoardConfig.mk 2>/dev/null
echo "########## env.cfg ##########"
cat device-a527/configs/cubie_a5e/debian/env.cfg 2>/dev/null
echo "########## sys_partition.fex ##########"
cat device-a527/configs/cubie_a5e/debian/sys_partition.fex 2>/dev/null
