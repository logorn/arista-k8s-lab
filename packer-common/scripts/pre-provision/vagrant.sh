#!/bin/bash

# Add vagrant public insecured key
mkdir -p /home/vagrant/.ssh || true
[ -f /provisioning/ssh-config ] && cp /provisioning/ssh-config /home/vagrant/.ssh/config || true
cat > /home/vagrant/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
EOF

# Add vagrant user to sudoers.
#cho "vagrant        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
echo 'vagrant ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/99_vagrant;
chmod 440 /etc/sudoers.d/99_vagrant;

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=sudo' /etc/sudoers;
