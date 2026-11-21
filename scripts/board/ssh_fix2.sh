#!/bin/bash
set -u
R(){ sshpass -p radxa ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=15 radxa@10.55.0.1 "$@"; }
RS(){ sshpass -p radxa ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=15 radxa@10.55.0.1 "echo radxa | sudo -S bash -c '$*'" ; }

echo '=== persist gateway + DNS in networkd ==='
RS 'cat > /etc/systemd/network/20-usb0.network <<EOF
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
cat /etc/systemd/network/20-usb0.network'

echo '=== apply now ==='
RS 'ip route replace default via 10.55.0.2 dev usb0; printf "nameserver 1.1.1.1\n" > /etc/resolv.conf; ip route | head -5'

echo '=== connectivity ==='
R 'ping -c 2 -W 2 1.1.1.1; ping -c 2 -W 3 deb.debian.org'

echo '=== apt update ==='
RS 'apt-get update 2>&1 | tail -4'

echo '=== install growpart ==='
RS 'DEBIAN_FRONTEND=noninteractive apt-get install -y cloud-guest-utils 2>&1 | tail -5'

echo '=== grow partition + fs ==='
RS 'growpart /dev/mmcblk0 3; partx -u /dev/mmcblk0 2>/dev/null; resize2fs /dev/mmcblk0p3 2>&1 | tail -3; df -h /'
