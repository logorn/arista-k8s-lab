#!/bin/bash

### TFTPD configuration
apt-get install -y tftpd-hpa
cp /vagrant/provisioner-config/ressources/tftpd-hpa /etc/default/tftpd-hpa
mkdir /tftpboot
cp -R /vagrant/provisioner-config/ressources/pxelinux.cfg /tftpboot
cp -R /vagrant/provisioner-config/ressources/syslinux /tftpboot
cp /vagrant/provisioner-config/ressources/pxelinux.0 /tftpboot
systemctl restart tftpd-hpa

### PXE configuration
apt-get install -y ipxe
