#!/bin/bash

mgt_itf="eth1"
data_itf="eth2"

my_mgt_ip=$(ip addr show ${mgt_itf} | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')
my_data_ip=$(ip addr show ${data_itf} | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')

echo "Management interface IP: ${my_mgt_ip}"

wget -O /tmp/crictl.tar.gz https://github.com/kubernetes-incubator/cri-tools/releases/download/v1.11.0/crictl-v1.11.0-linux-amd64.tar.gz
tar -xvzf /tmp/crictl.tar.gz -C /usr/bin/
chmod +x /usr/bin/crictl

swapoff -a
sed -i.bak 's/^\(\/dev\/mapper\/system--vg-swap\)/#\1/g' /etc/fstab

#kubeadm init --token $1 --feature-gates CoreDNS=true --apiserver-advertise-address=${my_mgt_ip} --apiserver-cert-extra-sans=${my_data_ip} --pod-network-cidr 172.22.0.0/16

#if [ $? -eq 1 ]; then
#  sed -i 's#Environment="KUBELET_KUBECONFIG_ARGS=\(.*\)"#Environment="KUBELET_KUBECONFIG_ARGS=\1 --node-ip='${my_mgt_ip}'"#g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
#else
#  sed -i -e 's/node-ip=[0-9]*.[0-9]*.[0-9]*.[0-9]*/node-ip='${my_mgt_ip}'/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
#fi

#systemctl daemon-reload
#systemctl restart kubelet
