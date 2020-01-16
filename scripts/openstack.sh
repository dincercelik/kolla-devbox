#!/bin/bash

set -e

source $(find . -maxdepth 2 -name config.sh -print)

test -e $BASE || mkdir -p $BASE && cd $BASE
test -z "$OPENSTACK_RELEASE" && REPOSITORY="master" || REPOSITORY="stable/$OPENSTACK_RELEASE"

if ! [ -e /usr/local/share/kolla ]; then
  test -e kolla || mkdir kolla && cd kolla

  echo "Downloading Kolla..."
  test -e setup.py || git clone https://github.com/openstack/kolla.git -b $REPOSITORY .

  echo "Installing dependencies..."
  pip3 install -r requirements.txt
  which tox || pip3 install tox

  echo "Installing Kolla..."
  tox -e genconfig
  python3 setup.py install

  echo "Installing configuration files..."
  install -m 0644 -D /usr/local/share/kolla/etc_examples/kolla/kolla-build.conf /etc/kolla/kolla-build.conf
fi

cd $BASE

if ! [ -e /usr/local/share/kolla-ansible ]; then
  test -e kolla-ansible || mkdir kolla-ansible && cd kolla-ansible

  echo "Downloading Kolla-Ansible..."
  test -e setup.py || git clone https://github.com/openstack/kolla-ansible.git -b $REPOSITORY .

  echo "Installing dependencies..."
  pip3 install -r requirements.txt

  echo "Installing Kolla-Ansible..."
  python3 setup.py install

  echo "Installing configuration files..."
  install -m 0644 -D /usr/local/share/kolla-ansible/etc_examples/kolla/globals.yml /etc/kolla/globals.yml
  install -m 0640 -D /usr/local/share/kolla-ansible/etc_examples/kolla/passwords.yml /etc/kolla/passwords.yml
  install -m 0644 -D /usr/local/share/kolla-ansible/ansible/inventory/all-in-one /etc/kolla/inventory/all-in-one
  install -m 0644 -D /usr/local/share/kolla-ansible/ansible/inventory/multinode /etc/kolla/inventory/multinode
fi

echo "Installing helpers..."
declare -A helpers
helpers["openstack"]="python-openstackclient"
helpers["nova"]="python-novaclient"
helpers["glance"]="python-glanceclient"
helpers["cinder"]="python-cinderclient"
helpers["neutron"]="python-neutronclient"

for helper in "${!helpers[@]}"; do
  which $helper || pip3 install ${helpers[$helper]}
done

echo "Setting permissions..."
chown -R $SUDO_USER:$SUDO_USER /etc/kolla

exit 0
