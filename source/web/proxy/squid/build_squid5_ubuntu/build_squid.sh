#!/bin/bash

if [[ $EUID -eq 0  ]]; then
      echo "This script must NOT be run as root" 1>&2
        exit 1
fi

# drop squid build folder
rm -R build/squid

# we will be working in a subfolder make it
mkdir -p build/squid

# set squid version
source squid.ver

# decend into working directory
pushd build/squid

# get squid from debian experimental
wget http://http.debian.net/debian/pool/main/s/squid/squid_${SQUID_PKG}.dsc
wget http://http.debian.net/debian/pool/main/s/squid/squid_${SQUID_VER}.orig.tar.xz
wget http://http.debian.net/debian/pool/main/s/squid/squid_${SQUID_VER}.orig.tar.xz.asc
wget http://http.debian.net/debian/pool/main/s/squid/squid_${SQUID_PKG}.debian.tar.xz

# unpack the source package
dpkg-source -x squid_${SQUID_PKG}.dsc

# build the package
cd squid-${SQUID_VER} && dpkg-buildpackage -rfakeroot -b -us -uc

# and revert
popd
