#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

echo "Installing dependencies..."
apt -y install apt-transport-https ca-certificates curl software-properties-common

echo "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
command -v docker || apt -y install docker-ce
usermod -a -G docker "$SUDO_USER"

exit 0
