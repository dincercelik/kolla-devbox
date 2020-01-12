#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

echo "Updating system..."
apt -yqq update
apt -yqq full-upgrade

echo "Installing Python..."
which python3 || apt-get -yqq install python3-minimal

echo "Installing Pip..."
which pip3 || apt-get -yqq install python3-pip

echo "Installing Ansible..."
add-apt-repository -y ppa:ansible/ansible-2.9
which ansible || apt -yqq install ansible

echo "Installing Git..."
which git || apt -yqq install git

exit 0
