# Network Plan

## Addressing — 10.10.0.0/24, domain `office.lab`

| Host | IP | Role |
|---|---|---|
| gw01 | 10.10.0.1 | Default gateway, NAT, firewall, Squid |
| ctl01 | 10.10.0.5 | Ansible control node |
| dns01 | 10.10.0.10 | BIND master, Kea DHCP |
| dns02 | 10.10.0.11 | BIND slave |
| web01 | 10.10.0.20, 10.10.0.21 | Apache (.21 = IP-based vhost) |
| mail01 | 10.10.0.30 | Postfix, Dovecot |
| files01 | 10.10.0.40 | Samba, vsftpd, CUPS |
| mon01 | 10.10.0.50 | Nagios, rsyslog |
| DHCP pool | 10.10.0.100 – 10.10.0.200 | Clients |
| Broadcast | 10.10.0.255 | |

## VLSM exercise (Unit 1 — do by hand first, then verify)

The Phase 3 stretch (DHCP relay) adds more subnets. Plan them from **10.10.0.0/22** using VLSM — largest first:

| Subnet | Hosts needed | Prefix | Network | Usable range | Broadcast |
|---|---|---|---|---|---|
| Staff LAN | 200 | | | | |
| Servers | 50 | | | | |
| Guest Wi-Fi | 25 | | | | |
| gw01 ↔ branch link | 2 | | | | |

Then: which single CIDR route summarises all four? Show the common prefix bits.

## Ports used

| Service | Port / proto |
|---|---|
| SSH | 22/tcp |
| DNS | 53/udp, 53/tcp (zone transfer) |
| DHCP | 67/udp server, 68/udp client |
| HTTP / HTTPS | 80, 443/tcp |
| Squid | 3128/tcp |
| SMTP | 25/tcp |
| POP3 / IMAP | 110, 143/tcp |
| FTP | 21/tcp + passive range |
| Samba | 445/tcp |
| CUPS (IPP) | 631/tcp |
| Nagios web | 80/tcp on mon01 |
| rsyslog | 514/tcp |
