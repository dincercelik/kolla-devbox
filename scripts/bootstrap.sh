#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

echo "Updating system..."
apt -yqq update
apt -yqq full-upgrade

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
