#!/bin/bash
set -x
cat > /etc/systemd/network/20-usb0.network <<'EOF'
[Match]
Name=usb0

[Network]
Address=10.55.0.1/24
Gateway=10.55.0.2
DNS=1.1.1.1
DHCPServer=yes
ConfigureWithoutCarrier=yes

[DHCPServer]
PoolOffset=10
PoolSize=20
EmitDNS=no
EOF
cat /etc/systemd/network/20-usb0.network

ip route replace default via 10.55.0.2 dev usb0
printf 'nameserver 1.1.1.1\nnameserver 1.0.0.1\n' > /etc/resolv.conf

ip route
cat /etc/resolv.conf
ping -c 2 -W 2 1.1.1.1
getent hosts deb.debian.org

export DEBIAN_FRONTEND=noninteractive
apt-get update 2>&1 | tail -4
apt-get install -y cloud-guest-utils 2>&1 | tail -4

growpart /dev/mmcblk0 3
partx -u /dev/mmcblk0 2>/dev/null
resize2fs /dev/mmcblk0p3 2>&1 | tail -3
df -h /
