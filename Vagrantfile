# -*- mode: ruby -*-
# Office in a Box — lab VMs for BIT 451 (Network & System Administration)
#
#   vagrant up                 # all VMs (needs ~6 GB free RAM)
#   vagrant up ctl01 gw01 dns01 client01    # only what the current phase needs
#   vagrant ssh ctl01          # Ansible runs from here (Ansible can't run on Windows)
#
# Network: every VM's eth1 is on the VirtualBox *internal* network "office" (10.10.0.0/24).
# eth0 is Vagrant's NAT adapter — used only for `vagrant ssh` and the very first package install.
# Once gw01 routes + NATs, the `common` role moves each server's default route to gw01 (see ROADMAP).

LAB_NET = "office"
SERVER_BOX = "bento/rockylinux-9"
CLIENT_BOX = "bento/ubuntu-24.04"

# name => [ip, memory_mb]
SERVERS = {
  "gw01"    => ["10.10.0.1",  512],   # router, firewall, Squid proxy
  "dns01"   => ["10.10.0.10", 512],   # BIND master + Kea DHCP
  "dns02"   => ["10.10.0.11", 512],   # BIND slave
  "web01"   => ["10.10.0.20", 512],   # Apache (2nd IP .21 added in phase 5 for IP-based vhost)
  "mail01"  => ["10.10.0.30", 1024],  # Postfix + Dovecot + SpamAssassin
  "files01" => ["10.10.0.40", 512],   # Samba, vsftpd, CUPS (+ 2nd disk for LVM)
  "mon01"   => ["10.10.0.50", 768],   # Nagios Core, central rsyslog
}

# Lab-only SSH key: created by ctl01, trusted by every server. Never reuse outside this lab.
TRUST_LAB_KEY = <<~SHELL
  if [ -f /vagrant/.lab-keys/id_ed25519.pub ]; then
    install -d -m 700 -o vagrant -g vagrant /home/vagrant/.ssh
    grep -qxF "$(cat /vagrant/.lab-keys/id_ed25519.pub)" /home/vagrant/.ssh/authorized_keys 2>/dev/null \
      || cat /vagrant/.lab-keys/id_ed25519.pub >> /home/vagrant/.ssh/authorized_keys
    chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
    chmod 600 /home/vagrant/.ssh/authorized_keys
  else
    echo "WARN: lab key missing — run 'vagrant up ctl01' first, then 'vagrant provision $(hostname -s)'"
  fi
SHELL

Vagrant.configure("2") do |config|
  config.vm.box_check_update = false

  # ---- ctl01: Ansible control node — defined FIRST so it is created (and makes the key) first ----
  config.vm.define "ctl01", primary: true do |m|
    m.vm.box = SERVER_BOX
    m.vm.hostname = "ctl01.office.lab"
    m.vm.network "private_network", ip: "10.10.0.5", virtualbox__intnet: LAB_NET
    m.vm.provider("virtualbox") { |vb| vb.memory = 768; vb.cpus = 1; vb.name = "oib-ctl01" }
    m.vm.provision "shell", inline: <<~SHELL
      set -e
      dnf -y install epel-release
      dnf -y install ansible-core git bind-utils curl nmap-ncat
      ansible-galaxy collection install ansible.posix community.general
      install -d /vagrant/.lab-keys
      [ -f /vagrant/.lab-keys/id_ed25519 ] || ssh-keygen -t ed25519 -N "" -C "office-lab" -f /vagrant/.lab-keys/id_ed25519
      # Shared folders have loose permissions, and ssh refuses loose keys -> copy into ~/.ssh
      install -d -m 700 -o vagrant -g vagrant /home/vagrant/.ssh
      install -m 600 -o vagrant -g vagrant /vagrant/.lab-keys/id_ed25519 /home/vagrant/.ssh/lab_ed25519
      echo 'cd /vagrant/ansible' >> /home/vagrant/.bashrc
    SHELL
  end

  # ---- servers ----
  SERVERS.each do |name, (ip, mem)|
    config.vm.define name do |m|
      m.vm.box = SERVER_BOX
      m.vm.hostname = "#{name}.office.lab"
      m.vm.network "private_network", ip: ip, virtualbox__intnet: LAB_NET
      m.vm.provider "virtualbox" do |vb|
        vb.memory = mem
        vb.cpus = 1
        vb.name = "oib-#{name}"
        if name == "files01"
          # Phase 1: second 2 GB disk for the LVM exercise (PV -> VG -> LV, then extend live)
          # If `vagrant up files01` fails here, check the controller name with:
          #   VBoxManage showvminfo oib-files01 | grep "Storage Controller Name"
          # and replace "SATA Controller" below.
          disk = File.join(File.dirname(__FILE__), ".vagrant", "files01-data.vdi")
          vb.customize ["createhd", "--filename", disk, "--size", 2048] unless File.exist?(disk)
          vb.customize ["storageattach", :id, "--storagectl", "SATA Controller",
                        "--port", 1, "--device", 0, "--type", "hdd", "--medium", disk]
        end
      end
      m.vm.provision "shell", inline: TRUST_LAB_KEY
    end
  end

  # ---- client01: employee laptop. No static IP on purpose — it must get one from OUR DHCP (Kea). ----
  # auto_config: false -> Vagrant does not configure eth1; the guest asks for DHCP on it.
  # The "office" internal network has no VirtualBox DHCP, so if Kea is down you'll see 169.254.x.x (APIPA).
  config.vm.define "client01" do |m|
    m.vm.box = CLIENT_BOX
    m.vm.hostname = "client01"
    m.vm.network "private_network", ip: "10.10.0.250", virtualbox__intnet: LAB_NET, auto_config: false
    m.vm.provider("virtualbox") { |vb| vb.memory = 1024; vb.cpus = 1; vb.name = "oib-client01" }
    m.vm.provision "shell", inline: TRUST_LAB_KEY
  end
end
