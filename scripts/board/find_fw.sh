#!/bin/bash
cd /home/akar/cubie-a5e-fw
echo '=== aic firmware in kernel tree ==='
find src/linux-aw2501 -iname '*8800*' 2>/dev/null | head -40
echo '=== aic dirs ==='
find src/linux-aw2501 -type d -iname '*aic*' 2>/dev/null | head
echo '=== reference image firmware (if cached) ==='
ls cache/ 2>/dev/null
echo '=== search rtw8852 in kernel tree ==='
find src/linux-aw2501 -iname '*8852*' 2>/dev/null | head -20
