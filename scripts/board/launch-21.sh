#!/usr/bin/env bash
cd /home/akar/cubie-a5e-fw
nohup bash /mnt/c/Users/akant/AppData/Local/Temp/opencode/21-kernel-build.sh > /home/akar/cubie-a5e-fw/logs/21-kernel-build.nohup 2>&1 &
echo "LAUNCHED_PID=$!"
