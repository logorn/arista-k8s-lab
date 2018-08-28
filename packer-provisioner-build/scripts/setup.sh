#!/bin/bash -eux

export DEBIAN_FRONTEND=noninteractive

hostnamectl set-hostname "provisioner"

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

apt-get install policykit-1 -y

echo "Installation completed..."

cat <<'EOF' >/usr/local/bin/firstboot.sh
#!/bin/bash
(
  flock -n 200 || exit 1
  if [ ! -f ~/firstboot ]; then
    cd /provisioning
    ansible-playbook ./provisioner.yml
    [ $? -eq 0 ] && touch ~/firstboot || exit 1
  fi
) 200>/var/lock/firstboot.lock
EOF

chmod 755 /usr/local/bin/firstboot.sh

cat <<'EOF' >/etc/systemd/system/firstboot.service;
[Unit]
Description=first boot
Wants=network-online.target
After=network-online.target
StartLimitInterval=200
StartLimitBurst=5

[Service]
Type=simple
ExecStart=/usr/local/bin/firstboot.sh
RestartSec=10
Restart=on-failure
StandardOutput=journal
User=vagrant
Group=vagrant

[Install]
#WantedBy=multi-user.target
WantedBy=sysinit.target
EOF

systemctl daemon-reload
systemctl enable firstboot

#su - vagrant -c "cd /provisioning && ansible-playbook ./provisioner.yml"
