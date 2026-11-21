param([int]$Wait = 50)
Start-Sleep -Seconds $Wait
$k = 'C:\Users\akant\.ssh\cubie_a5e'
$o = '-o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL -o ConnectTimeout=10'
for ($i = 1; $i -le 20; $i++) {
    $r = & cmd /c "ssh -i $k $o radxa@10.55.0.1 `"echo UP`" 2>&1"
    if ("$r" -match 'UP') { Write-Host "ssh up after $i tries"; break }
    Start-Sleep -Seconds 10
}
& cmd /c "ssh -i $k $o radxa@10.55.0.1 `"uptime; systemctl is-active aic8800-bt bluetooth zramswap systemd-timesyncd; cat /proc/swaps; nmcli -t dev status | head -6; ip -br addr show wlan0; systemctl --failed --no-pager`""
