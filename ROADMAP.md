# Roadmap

Tick boxes as you go. Each phase ends with: role working → `smoke.sh` section passing → `docs/` page written → commit.

Tags: **⭐⭐** asked 2081 + 2082 · **⭐** asked once · **🔮** syllabus, not asked yet.

---

## Phase 1 — Base servers · Unit 2 · ~4 h
Role: `common` · Doc: `docs/01-linux-server.md`

- [ ] `vagrant up ctl01`, then `vagrant up` the rest; `ansible all -m ping` works from ctl01
- [ ] `common`: hostname, `/etc/hosts`, timezone, chrony, base packages, `dnf upgrade`
- [ ] `common`: `labadmin` group + users, `/etc/sudoers.d/labadmin` (validate with `visudo -cf`)
- [ ] `common`: SSH hardening (no root login, key only) — keep the `vagrant` user working!
- [ ] files01: LVM on `/dev/sdb` → PV → VG `vg_data` → LV `lv_share` 1 GB → xfs → mount `/srv/share` → extend to 1.5 GB live
- **Answers:** ⭐⭐ Linux server install/features (2081 Q1, 2082 Q1) · 🔮 LVM · 🔮 users/groups/sudo

## Phase 2 — Router + firewall · Units 1, 3 · ~5 h
Role: `firewall` · Doc: `docs/02-firewall-and-routing.md`

- [ ] gw01: `net.ipv4.ip_forward=1`, masquerade LAN → NAT adapter (eth0)
- [ ] `common` (servers + client): default route via `10.10.0.1` on eth1, DNS → dns01 (only after gw01 forwards!)
- [ ] Packet filter: default drop inbound; allow SSH from 10.10.0.5 only; forward HTTP/S, DNS, SMTP as needed; log drops
- [ ] Break/fix drills with `ip`, `ping`, `traceroute`, `ss`, `dig`, `tcpdump` — record each in the doc
- **Answers:** ⭐⭐ Firewall need, packet-level (2081 Q3, 2082 Q4) · 🔮 troubleshooting commands · 🔮 network startup issues

## Phase 3 — DHCP · Unit 4 · ~3 h
Role: `dhcp` · Doc: `docs/03-dhcp.md`

- [ ] Kea DHCPv4 on dns01: pool `.100–.200`, options 3 (router), 6 (DNS), 15 (domain), lease time
- [ ] Reservation for client01's MAC
- [ ] `tcpdump -ni eth1 port 67 or port 68` → capture DORA, paste in doc
- [ ] Drills: Kea stopped (APIPA), pool exhausted, firewall blocks UDP 67
- [ ] Stretch: second subnet + DHCP relay on gw01
- **Answers:** ⭐ DHCP options (2081 Q10) · ⭐ DHCP troubleshooting (2082 Q8) · 🔮 DORA · 🔮 relay

## Phase 4 — DNS · Unit 5 · ~6 h
Roles: `dns_master`, `dns_slave` · Doc: `docs/04-dns.md`

- [ ] dns01 master: forward zone `office.lab` + reverse `0.10.10.in-addr.arpa` (templates in role)
- [ ] dns02 slave: `allow-transfer` + `also-notify` on master; bump serial → watch NOTIFY + transfer in logs
- [ ] `dig @10.10.0.11 office.lab AXFR` from ctl01 → then restrict transfers, show it's refused from client01
- [ ] Caching-only forwarder on gw01 (or dns01 recursion for LAN only)
- [ ] Kea DDNS → BIND dynamic updates (TSIG key)
- [ ] Delegate `dev.office.lab` to dns02
- **Answers:** ⭐⭐ Zone transfer (2081 Q9, 2082 Q7) · ⭐ DNS principles + server types (2082 Q2) · 🔮 recursive vs iterative · 🔮 caching-only · 🔮 DDNS · 🔮 delegation

## Phase 5 — Web + proxy · Unit 6 · ~7 h
Roles: `web`, `proxy` · Docs: `docs/05-web-server.md`, `docs/06-proxy.md`

- [ ] Apache name-based vhosts: `www.office.lab`, `intranet.office.lab`
- [ ] Second IP `10.10.0.21` → IP-based vhost `shop.office.lab`
- [ ] HTTPS on one vhost (own lab CA)
- [ ] Squid on gw01: caching (`TCP_HIT`/`TCP_MISS`), ACLs (blocklist, lunch-time rule, admin bypass)
- [ ] `delay_pools` bandwidth limit; optional `tc` shaping
- [ ] Transparent proxy (redirect :80) = application-level firewall
- **Answers:** ⭐⭐ Virtual hosting (2081 Q2, 2082 Q3) · ⭐ Proxy ACL (2082 Q3) · ⭐ Bandwidth mgmt (2081 Q8) · ⭐ Web server config (2082 Q6)

## Phase 6 — File, FTP, print · Unit 7 · ~5 h
Roles: `files`, `print` · Doc: `docs/07-file-ftp-print.md`

- [ ] Samba: `public` share + `accounts` share for group `acct` only; map from Windows
- [ ] vsftpd: local users chrooted + anonymous read-only `/var/ftp/pub`; passive ports in firewall
- [ ] tcpdump an FTP login → control vs data channel, plaintext password
- [ ] CUPS + `cups-pdf` shared printer; print from client01
- **Answers:** ⭐ FTP + anonymous FTP (2081 Q7) · ⭐ CUPS (2082 Q12) · 🔮 smb.conf

## Phase 7 — Mail · Unit 8 · ~7 h
Role: `mail` · Doc: `docs/08-mail.md`

- [ ] Postfix for `office.lab`, `mynetworks = 10.10.0.0/24` (no open relay)
- [ ] Prove relay policy: LAN allowed, outside → `554 Relay access denied`
- [ ] Manual SMTP session with `nc mail01 25` → paste transcript in doc
- [ ] Dovecot IMAP + POP3; compare in Thunderbird (client01)
- [ ] SpamAssassin; GTUBE test message gets tagged
- [ ] SPF / DKIM / DMARC records in zone (explain in doc)
- **Answers:** ⭐⭐ SMTP + relay (2081 Q6, 2082 Q12) · 🔮 POP vs IMAP · 🔮 Postfix config · 🔮 spam control

## Phase 8 — Monitoring + scheduled ops · Units 2, 3 · ~4 h
Role: `monitoring` (+ cron/anacron in `common`) · Doc: `docs/09-monitoring-and-scheduling.md`

- [ ] Nagios Core on mon01: host + service checks for every VM (ping, SSH, HTTP, DNS, SMTP, disk, load)
- [ ] Email notification to `admin@office.lab`; stop Apache → CRITICAL → RECOVERY
- [ ] Nightly config backup via cron; weekly cleanup via anacron
- [ ] rsyslog forwarding from all VMs to mon01
- **Answers:** ⭐ Nagios (2082 Q11) · ⭐ Monitoring how/why (2081 Q5) · ⭐⭐ cron/anacron (2081 Q1, 2082 Q10) · 🔮 log analysis

## Phase 9 — Online upgrade + rebuild proof · ~2 h
Doc: add to `docs/01-linux-server.md`

- [ ] Live `dnf upgrade` on web01 while it serves traffic; `dnf history`; new kernel; `grubby` rollback
- [ ] `vagrant destroy -f` → rebuild → `site.yml` → `smoke.sh` all green
- [ ] Screen recording (2 min) for README
- **Answers:** ⭐⭐ Online server upgrade (2082 Q1)

---

## Traps

1. **Ansible can't run on Windows** → always run it from `ctl01`.
2. **Traffic bypassing gw01** — every VM also has Vagrant's NAT on eth0. Until the `common` role moves the default route to gw01, firewall/proxy tests prove nothing. Check with `ip route` and `traceroute 8.8.8.8` (first hop must be 10.10.0.1).
3. **Don't move the default route before gw01 forwards** — servers lose internet and `dnf` fails. `site.yml` runs the gateway play first for this reason.
4. **client01 shows 169.254.x.x** → Kea isn't answering (good DHCP troubleshooting material).
5. **SELinux / firewalld** block things by default. Fix properly (`semanage`, `restorecon`, `firewall-cmd`), never disable. Each fix → doc "Troubleshooting".
6. **Forgot to bump the zone serial** → dns02 never updates.
7. **Hyper-V / WSL2 enabled** → VirtualBox slow or VMs won't start. Disable Hyper-V for the lab, or switch Vagrant provider.
8. **RAM** — on 8 GB, run only what the phase needs: `vagrant up ctl01 gw01 dns01 client01`.
9. **Never commit `.lab-keys/` or real passwords** — use Ansible Vault for lab secrets.
