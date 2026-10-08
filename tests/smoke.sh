#!/usr/bin/env bash
# End-to-end checks for the lab. Run from ctl01:  bash /vagrant/tests/smoke.sh
# A check for a phase you haven't built yet just FAILs — that's your to-do list.
set -uo pipefail

KEY=~/.ssh/lab_ed25519
PASS=0; FAIL=0

check() { # description, command...
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "  PASS  $desc"; PASS=$((PASS+1))
  else echo "  FAIL  $desc"; FAIL=$((FAIL+1)); fi
}
on() { # host, remote command
  ssh -o BatchMode=yes -o ConnectTimeout=3 -i "$KEY" "vagrant@$1" "$2"
}
section() { echo; echo "== $1"; }

section "Phase 1 — base"
for h in 10.10.0.1 10.10.0.10 10.10.0.11 10.10.0.20 10.10.0.30 10.10.0.40 10.10.0.50; do
  check "ping $h" ping -c1 -W1 "$h"
done
check "LVM volume mounted on files01" on 10.10.0.40 "findmnt /srv/share"

section "Phase 2 — routing / firewall"
check "gw01 forwards (ip_forward=1)" on 10.10.0.1 "grep -qx 1 /proc/sys/net/ipv4/ip_forward"
check "web01 default route is gw01"  on 10.10.0.20 "ip route show default | grep -q 10.10.0.1"

section "Phase 3 — DHCP"
check "Kea listening on dns01 udp/67" on 10.10.0.10 "sudo ss -ulnp | grep -q ':67 '"

section "Phase 4 — DNS"
dns_has()   { [ -n "$(dig +short "@$1" "$2" "${3:-A}")" ]; }
serial_of() { dig +short "@$1" office.lab SOA | awk '{print $3}'; }
check "master answers www.office.lab"  dns_has 10.10.0.10 www.office.lab
check "slave answers www.office.lab"   dns_has 10.10.0.11 www.office.lab
check "MX record exists"               dns_has 10.10.0.10 office.lab MX
check "reverse 10.10.0.20 -> web01"    bash -c "dig +short @10.10.0.10 -x 10.10.0.20 | grep -q web01"
same_serial() { [ -n "$(serial_of 10.10.0.10)" ] && [ "$(serial_of 10.10.0.10)" = "$(serial_of 10.10.0.11)" ]; }
check "master and slave serials match" same_serial

section "Phase 5 — web / proxy"
check "name-based vhost www"      env PAGE_WORD=www      bash -c 'curl -s --max-time 3 --resolve www.office.lab:80:10.10.0.20 http://www.office.lab/ | grep -qi "$PAGE_WORD"'
check "name-based vhost intranet" env PAGE_WORD=intranet bash -c 'curl -s --max-time 3 --resolve intranet.office.lab:80:10.10.0.20 http://intranet.office.lab/ | grep -qi "$PAGE_WORD"'
check "IP-based vhost shop (.21)" env PAGE_WORD=shop     bash -c 'curl -s --max-time 3 http://10.10.0.21/ | grep -qi "$PAGE_WORD"'
check "Squid answers on 3128"     nc -z -w2 10.10.0.1 3128

section "Phase 6 — file / ftp / print"
check "Samba 445 open" nc -z -w2 10.10.0.40 445
check "FTP 21 open"    nc -z -w2 10.10.0.40 21
check "CUPS 631 open"  nc -z -w2 10.10.0.40 631

section "Phase 7 — mail"
smtp_banner() { printf 'QUIT\r\n' | nc -w3 10.10.0.30 25 | grep -q '^220'; }
check "SMTP 220 banner" smtp_banner
check "IMAP 143 open"   nc -z -w2 10.10.0.30 143
check "POP3 110 open"   nc -z -w2 10.10.0.30 110

section "Phase 8 — monitoring"
nagios_up() { curl -s --max-time 3 -o /dev/null -w '%{http_code}' http://10.10.0.50/nagios/ | grep -qE '200|401'; }
check "Nagios web UI" nagios_up

echo
echo "Result: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
