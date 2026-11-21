set -e
echo '=== before ==='
locale -a | tr '\n' ' '; echo

if grep -q '^# *en_US.UTF-8 UTF-8' /etc/locale.gen; then
    sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
elif ! grep -q '^en_US.UTF-8 UTF-8' /etc/locale.gen; then
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
fi

locale-gen 2>&1 | tail -3
update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en 2>&1 || update-locale LANG=en_US.UTF-8

echo '=== after ==='
locale -a | tr '\n' ' '; echo
cat /etc/default/locale
echo '=== charmap in a login-like env ==='
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 locale charmap
echo '=== btop under a pty, 3 s ==='
if command -v script >/dev/null; then
    timeout 4 script -qc 'LANG=en_US.UTF-8 TERM=xterm-256color btop' /dev/null >/tmp/btop_test.log 2>&1 || true
    if grep -qi 'No UTF-8 locale' /tmp/btop_test.log; then
        echo 'STILL BROKEN'
    else
        echo 'btop started without the locale error'
    fi
    head -3 /tmp/btop_test.log | cat -v | head -3
else
    echo 'script(1) missing, skipped pty test'
fi
