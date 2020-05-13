#!/bin/bash

set -e

if [[ "$SUDO_USER" == "vagrant" ]]; then
  CONFIG="/openstack/config.sh"
  SAMPLES="/openstack/samples"
else
  CONFIG=$(find "$PWD" -maxdepth 2 -type f -name config.sh -print)
  SAMPLES=$(find "$PWD" -maxdepth 2 -type d -name samples -print)
fi

source "$CONFIG"

test -e "$BASE" || mkdir -p "$BASE" && cd "$BASE"
test -z "$OPENSTACK_RELEASE" && REPOSITORY="master" || REPOSITORY="stable/$OPENSTACK_RELEASE"
[[ "$OPENSTACK_RELEASE" == "stein" ]] && PYTHON_VERSION=2 || PYTHON_VERSION=3
PYTHON="python$PYTHON_VERSION"
PIP="pip$PYTHON_VERSION"
test -e /etc/alternatives/python || update-alternatives --install /usr/bin/python python /usr/bin/$PYTHON 10

echo "Installing Ansible..."
command -v ansible || $PIP install ansible==2.9.*

if [[ ! -e /usr/local/share/kolla ]]; then
  test -e kolla || mkdir kolla && cd kolla

  echo "Downloading Kolla..."
  test -e setup.py || git clone https://opendev.org/openstack/kolla.git -b "$REPOSITORY" .

  echo "Installing dependencies..."
  $PIP install -r requirements.txt
  command -v tox || $PIP install tox

  echo "Installing Kolla..."
  tox -e genconfig
  $PYTHON setup.py install

  echo "Installing configuration files..."
  install -m 0644 -D /usr/local/share/kolla/etc_examples/kolla/kolla-build.conf /etc/kolla/kolla-build.conf
  install -m 0644 -D "$SAMPLES/kolla-build.conf" /etc/kolla/kolla-build.conf -b -S -dist
fi

cd "$BASE"

if [[ ! -e /usr/local/share/kolla-ansible ]]; then
  test -e kolla-ansible || mkdir kolla-ansible && cd kolla-ansible

  echo "Downloading Kolla-Ansible..."
  test -e setup.py || git clone https://opendev.org/openstack/kolla-ansible.git -b "$REPOSITORY" .

  echo "Installing dependencies..."
  $PIP install -r requirements.txt

  echo "Installing Kolla-Ansible..."
  $PYTHON setup.py install

  echo "Installing configuration files..."
  install -m 0644 -D "$BASE/kolla-ansible/contrib/bash-completion/kolla-ansible" /etc/bash_completion.d/kolla-ansible
  install -m 0644 -D /usr/local/share/kolla-ansible/etc_examples/kolla/globals.yml /etc/kolla/globals.yml
  install -m 0640 -D /usr/local/share/kolla-ansible/etc_examples/kolla/passwords.yml /etc/kolla/passwords.yml
  install -m 0644 -D /usr/local/share/kolla-ansible/ansible/inventory/all-in-one /etc/kolla/inventory/all-in-one
  install -m 0644 -D /usr/local/share/kolla-ansible/ansible/inventory/multinode /etc/kolla/inventory/multinode
  install -m 0644 -D "$SAMPLES/globals.yml" /etc/kolla/globals.yml -b -S -dist
fi

echo "Installing helpers..."
declare -A helpers
helpers["openstack"]="python-openstackclient"
helpers["nova"]="python-novaclient"
helpers["glance"]="python-glanceclient"
helpers["cinder"]="python-cinderclient"
helpers["neutron"]="python-neutronclient"

for helper in "${!helpers[@]}"; do
  command -v $helper || $PIP install -I -c "https://opendev.org/openstack/requirements/raw/branch/$REPOSITORY/upper-constraints.txt" ${helpers[$helper]}
done

echo "Setting permissions..."
chown -R "$SUDO_UID:$SUDO_GID" /etc/kolla

exit 0
