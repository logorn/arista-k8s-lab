# -*- mode: ruby -*-
# vi: set ft=ruby :

# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VER = "2"

# Plugins we require
required_plugins = %w(vagrant-vbguest vagrant-host-shell)

##### START Helper functions
def install_ssh_key()
  puts "Adding ssh key to the ssh agent"
  puts "ssh-add #{Vagrant.source_root}/keys/vagrant"
  system "ssh-add #{Vagrant.source_root}/keys/vagrant"
end

def install_plugins(required_plugins)
  plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
  if not plugins_to_install.empty?
    puts "Installing plugins: #{plugins_to_install.join(' ')}"
    if system "vagrant plugin install #{plugins_to_install.join(' ')}"
      exec "vagrant #{ARGV.join(' ')}"
    else
      abort "Installation of one or more plugins has failed. Aborting."
    end
  end
end
##### END Helper functions

# Install ssh key
#
# Uncomment the next line if you're using ssh-agent
# install_ssh_key

# Check certain plugins are installed
install_plugins required_plugins

# Require YAML module
require 'yaml'

# Read YAML file with box details
vagrant_root = File.dirname(__FILE__)
hosts = YAML.load_file(vagrant_root + '/topology.yml')

# Lab definition begins here
Vagrant.configure(VAGRANTFILE_API_VER) do |config|

  config.vm.provider "libvirt"
  config.vm.provider "virtualbox"

  config.vm.boot_timeout = 600

  config.vbguest.auto_update = false

  # Iterate through entries in YAML file
  hosts.each do |host|

    config.vm.define host["name"] do |srv|

      script = ""

      config.ssh.insert_key = false

      args = Array.new
      args.push(host["name"])

      srv.vm.provider :libvirt do |libvirt, override|

        override.vm.box = host["box"]["libvirtbox"]
        override.vm.box_version = host["box"]["libvirtbox_version"]
        if /provisioner/.match(host['name'])
          override.vm.synced_folder '.', '/vagrant', id: "vagrant-root", disabled: true
          override.vm.synced_folder '.', '/provisioning', type: 'rsync',
            rsync__exclude: [ ".gitignore", ".git/", "misc", "packer-provisioner-build", ".vagrant", "*.qcow2", "*.vmdk", "*.box" ]
        else
          if /(?i:veos)/.match(host['box']['vbox'])
            override.vm.synced_folder '.', '/vagrant', id: "vagrant-root", disabled: true
            libvirt.disk_bus = 'ide'
            libvirt.cpus = 1

            script += <<-SCRIPT
bash sudo su || bash -c 'sudo su'
SCRIPT
          elsif /(?i:k8s-.*)/.match(host['name'])
            #libvirt.storage :file, :size => '10G', :type => 'qcow2'
            boot_network = {'network' => 'mgmt'}
            libvirt.boot boot_network
            libvirt.boot 'hd'
          end
        end

        if host.key?("ram")
          libvirt.memory = host["ram"]
        end
      end

      srv.vm.provider :virtualbox do |v, override|
        override.vm.box = host["box"]["vbox"]

        if /provisioner/.match(host['name'])
          override.vm.synced_folder '.', '/vagrant', id: "vagrant-root", disabled: true
          override.vm.synced_folder '.', '/provisioning', type: 'rsync',
            rsync__exclude: [ ".gitignore", ".git/", "misc", "packer-provisioner-build", ".vagrant", "*.qcow2", "*.vmdk", "*.box" ]
        end

        if /(?i:k8s-.*)/.match(host['name'])
          v.customize [
            'modifyvm', :id,
            '--nicbootprio2', '1',
            '--boot1', 'net',
            '--boot2', 'none',
            '--boot3', 'none',
            '--boot4', 'none'
          ]
        end

        if host.key?("ram")
          v.memory = host["ram"]
        end
      end

      if host.key?("forwarded_ports")
        host["forwarded_ports"].each do |port|
          srv.vm.network :forwarded_port, guest: port["guest"], host: port["host"], id: port["name"]
        end
      end

      if host.key?("links")
        host["links"].each do |link|
          if link.key?("name")
            if link['name'] == "mgmt"
              $mgmtip = link["ip"]
            end

            srv.vm.provider :libvirt do |libvirt, ov|
              ov.vm.network "private_network",
                libvirt__network_name: link["name"],
                ip: ((link.key?("ip") ? (link["ip"] == "" ? "169.254.1.11" : link["ip"]) : "169.254.1.11")),
                libvirt__network_address: ((/(?i:k8s-.*)/.match(host['name']) && link["name"] == "mgmt") ? "10.0.5.0" : nil),
                type: "static",
                libvirt__forward_mode: "veryisolated",
                auto_config: (/(?i:veos)/.match(host['box']['vbox']) ? false : true),
                libvirt__dhcp_enabled: false,
                libvirt__mtu: 1500,
                model_type: "e1000",
                mac: (link.key?("mac") ? link["mac"] : nil)
            end

            srv.vm.provider :virtualbox do |v, ov|
              ov.vm.network "private_network",
                virtualbox__intnet: link["name"],
                ip: (link.key?("ip") ? link["ip"] : "169.254.1.11"),
                auto_config: (/(?i:veos)/.match(host['box']['vbox']) ? false : true),
                type: ((/(?i:k8s-.*)/.match(host['name']) && link["name"] == "mgmt") ? "dhcp" : "static"),
                mac: (link.key?("mac") ? link["mac"] : nil)
            end
          end
        end
      end

      script += <<-SCRIPT
export DEBIAN_FRONTEND=noninteractive
export VAGRANT=1
cp /etc/hosts /tmp/hosts
cat /tmp/hosts | /bin/sed 's/vagrant/'#{host['name']}'/g' > /etc/hosts
cp /etc/hosts /tmp/hosts
cat /tmp/hosts | /bin/sed 's/ubuntu1604\.localdomain/'#{host['name']}'/g' > /etc/hosts
if [ -f /provisioning/ssh-config ]; then
  mkdir -p /home/vagrant/.ssh
  cp /provisioning/ssh-config /home/vagrant/.ssh/config
fi
SCRIPT

      if /(?i:k8s-.*)/.match(host['name'])
        # libvirt dhcp hack
        script += <<-SCRIPT
ip addr flush dev eth1
dhclient eth1
sed -i -e '/^#VAGRANT-BEGIN$/{N; /\\n# The contents below are automatically generated by Vagrant\\. Do not modify\\.$/ {N; /\\nauto eth1$/ {N; /\\niface eth1 inet static$/ {N; /\\n      address 169.254.1.11$/ {N; /\\n      netmask 255.255.255.0$/ {N; /\\n#VAGRANT-END$/ { s/.*// }}}}}}}' /etc/network/interfaces

eth1here=$(cat /etc/network/interfaces | grep 'iface eth1 inet dhcp' 2>/dev/null | wc -l)
if [ "${eth1here}" == "0" ]; then
  echo -e "\\n#VAGRANT-HACK-BEGIN\\nauto eth1\\niface eth1 inet dhcp\\n#VAGRANT-HACK-END" >> /etc/network/interfaces
fi

SCRIPT
      end

      if /(?i:veos)/.match(host['box']['vbox'])
        script += <<-SCRIPT
FastCli -p 15 -c "configure
hostname $1
vrf definition MGMT
rd 1:1
interface Ethernet1
no switchport
vrf forwarding MGMT
ip address $2 255.255.255.0
wr mem"
SCRIPT

        args.push($mgmtip)
      else
        script += <<-SCRIPT
hostnamectl set-hostname $1
SCRIPT
      end

      if /provisioner/.match(host['name'])
        script += <<-SCRIPT
apt-get install software-properties-common -y
apt-add-repository ppa:ansible/ansible -y
apt-get update
apt-get install ansible -y
apt-get install python-pip -y
pip install ntc-ansible
echo "Installation completed..."
/usr/local/bin/firstboot.sh
#ansible-playbook ./site.yml
SCRIPT
        srv.vm.provision "shell", path: "./provisioner-config/setup.sh"
      end

      srv.vm.provision "shell" do |s|
        s.privileged = /(?i:veos)/.match(host['box']['vbox']) ? false : true
        s.inline = script
        s.args = args
      end
    end
  end
end
