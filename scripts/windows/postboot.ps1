param([int]$Wait = 60)
Start-Sleep -Seconds $Wait
$k = 'C:\Users\akant\.ssh\cubie_a5e'
$o = '-o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL -o ConnectTimeout=10'
for ($i = 1; $i -le 20; $i++) {
    $r = & cmd /c "ssh -i $k $o radxa@10.55.0.1 `"echo UP`" 2>&1"
    if ("$r" -match 'UP') { Write-Host "ssh up after $i tries"; break }
    Write-Host "try $i : $r"
    Start-Sleep -Seconds 10
}
Write-Host '=== post-boot state ==='
& cmd /c "ssh -i $k $o radxa@10.55.0.1 `"uname -r; uptime; date -u; lsmod | grep aic; nmcli -t dev status; ip -br addr show wlan0; ip route; df -h / | tail -1; systemctl --failed --no-pager`""
