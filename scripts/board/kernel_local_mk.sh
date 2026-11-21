#!/usr/bin/env bash
cd /home/akar/cubie-a5e-fw/src/linux-aw2501
echo "########## .github/local/Makefile.local ##########"
cat .github/local/Makefile.local 2>/dev/null
echo "########## radxa.config locations ##########"
find . -maxdepth 3 -name 'radxa.config' 2>/dev/null
echo "########## git status src ##########"
cd src && git status --porcelain | head -10
echo "########## current .config head ##########"
grep -m5 '^CONFIG_' .config 2>/dev/null
