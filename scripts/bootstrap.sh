#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

echo "Updating system..."
apt -yqq update
apt -yqq full-upgrade

echo "Setup fake ethernet..."
modprobe dummy
grep dummy /etc/modules || echo dummy | tee -a /etc/modules
ip link show fake_ethernet || ip link add fake_ethernet type dummy
test -e /etc/rc.local || printf "%s\n" "#!/bin/bash" "ip link add fake_ethernet type dummy" "exit 0" | tee -a /etc/rc.local && chmod +x /etc/rc.local

echo "Installing Python..."
which python3 || apt-get -yqq install python3-minimal
test -e /etc/alternatives/python || update-alternatives --install /usr/bin/python python /usr/bin/python3 10

echo "Installing Pip..."
which pip3 || apt-get -yqq install python3-pip

echo "Installing Ansible..."
which ansible || pip3 install ansible==2.9.*

echo "Installing Git..."
which git || apt -yqq install git

exit 0
