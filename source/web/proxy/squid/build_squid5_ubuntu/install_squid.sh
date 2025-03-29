#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# set squid version
source squid.ver

# decend into working directory
pushd build/squid

# install squid packages
sudo apt-get install squid-langpack
dpkg --install squid-common_${SQUID_PKG}_all.deb
dpkg --install squid-openssl_${SQUID_PKG}_amd64.deb
dpkg --install squidclient_${SQUID_PKG}_amd64.deb

# and revert
popd

# verify the installed squid binary
systemctl stop squid && systemctl start squid && systemctl status squid && /usr/sbin/squid -v
