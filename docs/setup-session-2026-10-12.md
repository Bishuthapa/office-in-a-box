# Setup Session — 2026-10-12

## Goal

Prepare the Windows host and bring up the virtual machines for the Office in a Box network administration lab.

## What we did

1. Confirmed the host prerequisites:
   - Vagrant: `2.4.9`
   - Oracle VirtualBox: `7.2.20r175154`
   - `VBoxManage` was not on PowerShell's PATH, but VirtualBox was installed and worked when called directly:
     `& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" --version`
   - `vagrant plugin list` reported no plugins installed. No extra plugin was needed for the project's built-in VirtualBox provider.
2. Started the Ansible control VM from the project directory:
   ```powershell
   vagrant up ctl01
   ```
   Vagrant reported that `ctl01` was already provisioned. The VM was running and `vagrant ssh ctl01` opened a shell at `/vagrant/ansible`.
3. Started the lab VMs. A later `vagrant status` confirmed all nine were running:
   `ctl01`, `gw01`, `dns01`, `dns02`, `web01`, `mail01`, `files01`, `mon01`, and `client01`.
4. Ran Ansible's ping module. The first command, `ansible all -m ping`, found no hosts because Ansible ignored `ansible.cfg` in the world-writable shared folder and had no inventory specified.
5. Specified the inventory explicitly. `ansible -i inventory.ini all -m ping` showed `pong` for reachable servers. `client01` initially failed at `10.10.0.150` with `No route to host`.
6. Rechecked the server group with:
   ```bash
   ansible -i inventory.ini servers -m ping
   ```
   All seven servers returned `SUCCESS` and `"ping": "pong"`:
   `gw01`, `dns01`, `dns02`, `web01`, `mail01`, `files01`, and `mon01`.

## Current state

- All nine VMs are running according to `vagrant status`.
- Ansible connectivity to the seven hosts in the `servers` group is confirmed.
- The initial `client01` ping did not work. Client networking depends on the DHCP phase, which has not been implemented yet.
- Ansible continues to warn that `/vagrant/ansible` is world-writable and ignores `ansible.cfg`. Specifying `-i inventory.ini` allowed the server connectivity check to work, but the config warning remains to be addressed.
- The project is still a skeleton. The Phase 1 `common` role is a placeholder; the service roles and later phases are not ready to configure the whole lab. Do not run the full `site.yml` expecting a complete office setup.

## Resume next time

1. Open PowerShell in the project folder and check VM state:
   ```powershell
   vagrant status
   ```
2. If the VMs are stopped, start them with `vagrant up`.
3. Connect to the control VM and reconfirm server access:
   ```powershell
   vagrant ssh ctl01
   ```
   ```bash
   ansible -i inventory.ini servers -m ping
   ```
4. Begin Phase 1 in `ROADMAP.md`: implement the `common` role, starting with hostnames and `/etc/hosts`. The role file is `ansible/roles/common/tasks/main.yml`.

No Ansible service configuration was applied during this session; the work today was prerequisite checks, VM startup, and connectivity verification.
