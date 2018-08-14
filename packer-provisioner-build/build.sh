#!/bin/bash

packer build \
  -var-file=variables.json \
  provisioner.json
#  -on-error=ask \
#  provisioner.json
