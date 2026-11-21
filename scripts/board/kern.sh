#!/usr/bin/env bash
set -uo pipefail
cd /tmp
echo "### kernel allwinner Makefile (allwinner-aiot-linux-6.6)"
curl -sL -m 40 https://raw.githubusercontent.com/radxa/kernel/allwinner-aiot-linux-6.6/arch/arm64/boot/dts/allwinner/Makefile -o kmk
wc -l kmk; grep -n 'cubie\|a527' kmk
echo
echo "### board.dts 6.6"
curl -sL -m 40 https://raw.githubusercontent.com/radxa/allwinner-device/device-a527-v1.5.0/configs/cubie_a5e/linux-6.6/board.dts -o b66.dts
wc -l b66.dts
grep -nE 'compatible = "radxa|model|wlan_busnum|sunxi-btlpm|uart_index|gmac1|&sdc1' b66.dts | sed -n '1,20p'
echo
echo "### aic8800-sdio-dkms content"
curl -sL -m 120 https://radxa-repo.github.io/trixie/pool/main/a/aic8800/aic8800-sdio-dkms_5.0+git20260123.5f7be68d-11_all.deb -o aicsdio.deb
dpkg-deb -c aicsdio.deb | awk '{print $6}' | grep -E 'dkms.conf|\.c$|\.h$|Makefile$' | sed -n '1,25p'
dpkg-deb -x aicsdio.deb aicx
echo "--- dkms.conf ---"
find aicx -name dkms.conf -exec grep -nE 'PACKAGE_NAME|BUILT_MODULE_NAME|DEST_MODULE' {} \;
