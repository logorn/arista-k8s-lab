#!/bin/bash

set +e
set +x

PACKER_VERSION="1.1.3"
RUBY_VERSION="2.3.6"
VAGRANT_VERSION="2.0.4"
RUBY_DEV_VERSION=$(echo ${RUBY_VERSION} | sed -e 's/\([0-9]*\.[0-9]*\)\.[0-9]*/\1/')

CURRENT_DIR=$(pwd)
TEMP_DIR=$(mktemp -d)

VAGRANT_CURRENT_VERSION=$(vagrant -v 2>/dev/null | cut -d' ' -f 2)

echo "Vagrant Target: ${VAGRANT_VERSION}, Current: ${VAGRANT_CURRENT_VERSION}"

if [ "${VAGRANT_CURRENT_VERSION}" != "${VAGRANT_VERSION}" ]; then
  mkdir -p ${TEMP_DIR}/vagrant
  cd ${TEMP_DIR}/vagrant
  wget -O vagrant.tar.xz "https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.tar.xz?_ga=2.55669103.599991717.1518084132-2118798074.1518084132"
  sudo tar -xf vagrant.tar.xz -C /
fi

PACKER_CURRENT_VERSION=$(packer -v 2>/dev/null)

echo "Packer Target: ${PACKER_VERSION}, Current: ${PACKER_CURRENT_VERSION}"

if [ "${PACKER_CURRENT_VERSION}" != "${PACKER_VERSION}" ]; then
  mkdir -p ${TEMP_DIR}/packer
  cd ${TEMP_DIR}/packer
  wget -O packer.zip "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip?_ga=2.40003938.1369792823.1518341441-319495359.1518078262"
  unzip packer.zip
  sudo mv packer /usr/local/bin/packer
fi

cd ${TEMP_DIR}

which rvm > /dev/null 2>&1

if [ $? -eq 1 ]; then
  gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

  curl -sSL https://get.rvm.io > ./rvm_install.sh
  chmod +x ./rvm_install.sh
  ./rvm_install.sh
fi

source $HOME/.rvm/scripts/rvm || source /etc/profile.d/rvm.sh
rvm use --default --install ruby-${RUBY_VERSION}
rvm cleanup all

sudo apt-get install -y bsdtar nfs-kernel-server

cd ${CURRENT_DIR}
rm -rf ${TEMP_DIR}
