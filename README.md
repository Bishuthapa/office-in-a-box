# Office in a Box

A complete small-office network — DNS, DHCP, web, proxy, mail, file, print, monitoring, firewall —
built on VirtualBox VMs and configured entirely with Ansible. One command rebuilds the whole office from zero.

Built as the lab for a portfolio project.

> Status: skeleton. Follow [`ROADMAP.md`](ROADMAP.md) phase by phase.

## Topology

```
                Internet (VirtualBox NAT)
                        │
                 ┌──────┴──────┐
                 │    gw01     │  router + NAT + firewall (nftables/firewalld) + Squid proxy
                 │  10.10.0.1  │
                 └──────┬──────┘
           LAN 10.10.0.0/24 — VirtualBox internal network "office" — domain office.lab
 ┌────────┬────────┬────────┼────────┬─────────┬─────────┬──────────┐
ctl01    dns01    dns02    web01    mail01    files01    mon01     client01
.5       .10      .11      .20/.21  .30       .40        .50       DHCP
Ansible  BIND     BIND     Apache   Postfix   Samba      Nagios    Ubuntu
control  master   slave    vhosts   Dovecot   vsftpd     rsyslog   "employee
node     + Kea                      SpamAssn  CUPS, LVM            laptop"
```

| VM | IP | OS | Services | Syllabus unit |
|---|---|---|---|---|
| ctl01 | 10.10.0.5 | Rocky 9 | Ansible control node | — |
| gw01 | 10.10.0.1 | Rocky 9 | Routing, NAT, firewall, Squid | 3, 6 |
| dns01 | 10.10.0.10 | Rocky 9 | BIND master, Kea DHCP | 4, 5 |
| dns02 | 10.10.0.11 | Rocky 9 | BIND slave | 5 |
| web01 | 10.10.0.20, .21 | Rocky 9 | Apache name- and IP-based vhosts | 6 |
| mail01 | 10.10.0.30 | Rocky 9 | Postfix, Dovecot, SpamAssassin | 8 |
| files01 | 10.10.0.40 | Rocky 9 | Samba, vsftpd, CUPS, LVM disk | 2, 7 |
| mon01 | 10.10.0.50 | Rocky 9 | Nagios Core, central logs | 2, 3 |
| client01 | DHCP | Ubuntu 24.04 | Test client | all |

## Requirements

- VirtualBox 7.x, Vagrant 2.4+ (Windows, macOS or Linux host)
- ~6 GB free RAM for all VMs (or bring up only the ones a phase needs)
- Windows: Hyper-V / WSL2 can make VirtualBox slow — see ROADMAP "Traps"

Ansible runs **inside `ctl01`**, not on your host, so the host OS doesn't matter.

## Quick start

```bash
vagrant up ctl01                      # creates the control node + lab SSH key (do this first)
vagrant up                            # all other VMs
vagrant ssh ctl01                     # lands in /vagrant/ansible
ansible all -m ping                   # every server answers "pong"?
ansible-playbook site.yml             # configure everything
bash /vagrant/tests/smoke.sh          # prove it works
```

Rebuild from zero:

```bash
vagrant destroy -f && vagrant up ctl01 && vagrant up
vagrant ssh ctl01 -c "cd /vagrant/ansible && ansible-playbook site.yml && bash /vagrant/tests/smoke.sh"
```

## Repo layout

```
office-in-a-box/
├── Vagrantfile           all VMs + the "office" network
├── ROADMAP.md            9 phases, tasks, done-when, traps
├── ansible/
│   ├── ansible.cfg
│   ├── inventory.ini
│   ├── site.yml          which roles run on which hosts
│   ├── group_vars/all.yml   domain, IP plan, shared settings
│   └── roles/            one role per service (tasks, handlers, templates, defaults)
├── docs/                 one page per service, written as an exam answer
│   ├── 00-network-plan.md
│   ├── _TEMPLATE.md
│   ├── 01-…09-*.md
│   └── exam-map.md       past-paper question → page
└── tests/smoke.sh        end-to-end checks
```

## What I learned

_Fill in as you finish each phase._

## License

MIT (add a LICENSE file when you publish).
