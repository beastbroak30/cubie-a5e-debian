$ErrorActionPreference = 'Continue'
$ssh = 'ssh -i C:\Users\akant\.ssh\cubie_a5e -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL -o ConnectTimeout=10 radxa@10.55.0.1'
& cmd /c "$ssh `"uname -a; id`""
Write-Host '=== internet from board ==='
& cmd /c "$ssh `"ping -c 2 -W 2 1.1.1.1; getent hosts deb.debian.org`""
