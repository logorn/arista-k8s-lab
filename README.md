# arista-k8s-lab: Network Automation Lab around K8S + Arista

Aim of the project is to create a kubernetes cluster self-contained into virtualbox, create the spine-leaf architecture with virtual Arista TORs.

The lab is based on the following software:
* Arista vEOS
* Vagrant
* VirtualBox
* Ansible
* Kubernetes

The network design is a basic leaf/spine topology (AS per rack model) that will be built entirely using eBGP peerings.
The K8S network SDN is a calico full l3 solution ensuring pod networking.

## Launch the lab:

Please download the following arista veos virtualbox box on arista website: vEOS-lab-4.19.7M-virtualbox.box
Copy it at project root.
Launch and provision the lab using: vagrant up

* ... Have fun :)

