$ErrorActionPreference = 'Continue'
$k = 'C:\Users\akant\.ssh\cubie_a5e'
function R($cmd) {
    Write-Host ("`n>>> " + $cmd)
    & cmd /c "ssh -i $k -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL -o ConnectTimeout=15 radxa@10.55.0.1 `"$cmd`""
}

$net = 'cat > /etc/systemd/network/20-usb0.network <<EOF' + "`n" +
'[Match]' + "`n" + 'Name=usb0' + "`n`n" +
'[Network]' + "`n" + 'Address=10.55.0.1/24' + "`n" + 'Gateway=10.55.0.2' + "`n" + 'DNS=1.1.1.1' + "`n" +
'DHCPServer=yes' + "`n" + 'ConfigureWithoutCarrier=yes' + "`n`n" +
'[DHCPServer]' + "`n" + 'PoolOffset=10' + "`n" + 'PoolSize=20' + "`n" + 'EmitDNS=no' + "`n" + 'EOF' + "`n" +
'cat /etc/systemd/network/20-usb0.network'

R ("echo radxa | sudo -S bash -c `"$net`"")
R 'echo radxa | sudo -S ip route replace default via 10.55.0.2 dev usb0'
R 'echo radxa | sudo -S sh -c "printf ''nameserver 1.1.1.1\nnameserver 1.0.0.1\n'' > /etc/resolv.conf"'
R 'ip route; cat /etc/resolv.conf'
R 'ping -c 2 -W 2 1.1.1.1'
R 'getent hosts deb.debian.org'
R 'echo radxa | sudo -S apt-get update 2>&1 | tail -4'
R 'echo radxa | sudo -S env DEBIAN_FRONTEND=noninteractive apt-get install -y cloud-guest-utils 2>&1 | tail -4'
R 'echo radxa | sudo -S growpart /dev/mmcblk0 3'
R 'echo radxa | sudo -S resize2fs /dev/mmcblk0p3 2>&1 | tail -3'
R 'df -h /'
