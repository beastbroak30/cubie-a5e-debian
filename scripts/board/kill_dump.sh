#!/bin/bash
pkill -f p3_ncm.bin 2>/dev/null || true
pkill -f stage_ncm_p3.sh 2>/dev/null || true
sleep 1
ps -ef | grep -E 'dd |stage_ncm' | grep -v grep || true
losetup -a
