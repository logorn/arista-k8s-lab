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
  config.vbguest.auto_update = false

  # Iterate through entries in YAML file
  hosts.each do |host|

    config.vm.define host["name"] do |srv|

      args = Array.new
      args.push(host["name"])

      srv.vm.box = host["box"]
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
            ipaddr = "169.254.1.11"
            srv.vm.network "private_network", virtualbox__intnet: link["name"], ip: (link.key?("ip") ? link["ip"] : ipaddr), auto_config: (/vEOS/.match(host['box']) ? false : true)
          end
        end
      end

      script = <<-SCRIPT
export DEBIAN_FRONTEND=noninteractive
cp /etc/hosts /tmp/hosts
cat /tmp/hosts | /bin/sed 's/vagrant/'#{host['name']}'/g' > /etc/hosts
if [ -f /vagrant/ssh-config ]; then
  mkdir -p /home/vagrant/.ssh
  cp /vagrant/ssh-config /home/vagrant/.ssh/config
fi
SCRIPT

      if /vEOS/.match(host['box'])
        script += <<-SCRIPT
FastCli -p 15 -c "configure
hostname $1
vrf definition MGMT
rd 1:1
interface Eth1
no switchport
no shutdown
vrf forwarding MGMT
ip address $2 255.255.255.0"
SCRIPT

        args.push($mgmtip)
      else
        script += <<-SCRIPT
echo $1
hostnamectl set-hostname $1
SCRIPT
      end

      if /nms/.match(host['name'])
        script += <<-SCRIPT
apt-get install software-properties-common -y
apt-add-repository ppa:ansible/ansible -y
apt-get update
apt-get install ansible -y
apt-get install python-pip -y
pip install ntc-ansible
cd /vagrant
ansible-playbook ./site.yml
SCRIPT
      end

      if host.key?("ram")
        config.vm.provider "virtualbox" do |v|
          v.memory = host["ram"]
        end
      end

      srv.vm.provision "shell" do |s|
        s.inline = script
        s.args = args
      end
    end
  end
end
