#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive
printf "%s\n" 'APT::Install-Recommends "0";' 'APT::Install-Suggests "0";' | tee -a /etc/apt/apt.conf.d/01no-install-recommends

echo "Updating system..."
apt -y update
apt -y full-upgrade

echo "Setting up fake ethernet..."
modprobe dummy
grep dummy /etc/modules || echo dummy | tee -a /etc/modules
ip link show fake_ethernet || ip link add fake_ethernet type dummy
test -e /etc/rc.local || printf "%s\n" "#!/bin/bash" "ip link add fake_ethernet type dummy" "exit 0" | tee -a /etc/rc.local && chmod +x /etc/rc.local

echo "Installing development tools..."
apt -y install build-essential

echo "Installing Python..."
command -v python2 || apt-get -y install python-minimal python-dev
command -v python3 || apt-get -y install python3-minimal python3-dev

echo "Installing Pip..."
command -v pip2 || apt-get -y install python-pip
command -v pip3 || apt-get -y install python3-pip

for PIP in pip2 pip3; do
  $PIP install -U pip setuptools wheel
done

echo "Installing Git..."
command -v git || apt -y install git

exit 0
