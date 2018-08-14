#!/bin/bash

vagrant box remove virtualbox-provisioner
vagrant box add file://builds/virtualbox-provisioner.box --name virtualbox-provisioner
