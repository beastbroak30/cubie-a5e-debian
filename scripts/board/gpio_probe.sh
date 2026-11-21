#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get install -y -qq gpiod i2c-tools device-tree-compiler 2>&1 | tail -2
echo '=== gpiochips ==='
for c in /sys/class/gpio/gpiochip*; do echo "$(basename $c) label=$(cat $c/label 2>/dev/null) base=$(cat $c/base 2>/dev/null) ngpio=$(cat $c/ngpio 2>/dev/null)"; done
echo '=== gpioinfo (names only) ==='
gpioinfo 2>/dev/null | head -80
echo '=== debug gpio ==='
head -40 /sys/kernel/debug/gpio 2>/dev/null
echo '=== i2c/spi nodes ==='
ls /dev/i2c-* /dev/spidev* 2>&1
echo '=== pinctrl dt nodes on header-ish ==='
ls /sys/firmware/devicetree/base/pinctrl@300b000/ 2>/dev/null | head -40
