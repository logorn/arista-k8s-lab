#!/bin/bash

vagrant box remove virtualbox-provisioner
vagrant box add file://output-provisioner-vbox/virtualbox-provisioner.box --name virtualbox-provisioner
