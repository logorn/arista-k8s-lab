#!/bin/bash -eux

export DEBIAN_FRONTEND=noninteractive

hostnamectl set-hostname "provisioner"

# Disable daily apt unattended updates.
echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic

apt-get update
apt-get install software-properties-common -y
LC_ALL=C.UTF-8  apt-add-repository ppa:ansible/ansible -y
apt-get update
apt-get install ansible -y
apt-get install python-pip -y
pip install ntc-ansible

apt-get install jq -y
pip install yq
provisioner=$(cat /provisioning/group_vars/all.yml | yq -r '.provisioner')
mgmt_mask=$(cat /provisioning/group_vars/all.yml | yq -r '.mgmt_mask')

itf=$(ip link show | grep 'DOWN' | cut -d':' -f2)

ip address add ${provisioner}/${mgmt_mask} dev ${itf}

echo "Installation completed..."

su - vagrant -c "cd /provisioning && ansible-playbook ./provisioner.yml"
