#!/usr/bin/env bash
set -uo pipefail
grep -E "CONFIG_USB_CONFIGFS|CONFIG_USB_F_|CONFIG_USB_LIBCOMPOSITE|CONFIG_USB_U_ETHER|CONFIG_USB_U_SERIAL" /home/akar/cubie-a5e-fw/src/linux-aw2501/src/.config
