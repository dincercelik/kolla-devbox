#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

echo "Installing dependencies..."
apt -yqq install apt-transport-https ca-certificates curl software-properties-common

echo "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
which docker || apt -yqq install docker-ce
usermod -a -G docker $USER

exit 0
