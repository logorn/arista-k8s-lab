#!/bin/bash

#PACKER_LOG=1 packer build \
packer build \
  -var-file=variables-vbox.json \
  provisioner-vbox.json
#  -on-error=ask \

packer build \
  -var-file=variables-qemu-qcow2.json \
  provisioner-qemu.json

packer build \
  -var-file=variables-qemu-raw.json \
  provisioner-qemu.json
