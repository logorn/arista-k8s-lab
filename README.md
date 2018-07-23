# arista-k8s-lab: Network Automation Lab around K8S + Arista

Aim of the project is to create a kubernetes cluster self-contained into a local environment (one more).

Advantage of the solution is to reproduce locally a production grade networking.

This lab creates a simple spine-leaf architecture with virtual veos virtual machines.

You will have:
* One spine
* Two leaves
* A k8s master node and a worker node under first leaf
* Another worker node under the second leaf

The lab is based on the following software:
* Arista vEOS
* Vagrant
* VirtualBox/Libvirt
* Ansible
* Kubernetes
* Calico

The network design is a basic leaf/spine topology (AS per rack model) that will be built entirely using eBGP peerings.

The K8S network SDN is a calico full l3 solution ensuring pod networking.

## Launch the lab:

Please register on arista website and download the following arista veos virtualbox image on arista website: vEOS-lab-4.19.7M-virtualbox.box

Copy it at project root.
Launch and provision the lab using: vagrant up

* Enjoy :)
