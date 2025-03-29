#!/bin/sh
# Name: startdebianvm
# Purpose: Simple script to start my Debian 10 VM using bhyve on FreeBSD
# Author: Vivek Gite {https://www.cyberciti.biz} under GPL v2.x+
-------------------------------------------------------------------------
# Lazy failsafe (not needed but I will leave them here)
# 我简单修改适应我的环境
ifconfig tap1 create
ifconfig wifibox0 addm tap0
if ! kldstat | grep -w vmm.ko 
then
	kldload -v vmm
fi
if ! kldstat | grep -w nmdm.ko
then
	kldload -v nmdm
fi
bhyve -c 1 -m 1G -w -H \
-s 0,hostbridge \
-s 4,virtio-blk,/dev/zvol/zroot/vms/debian \
-s 5,virtio-net,tap1 \
-s 29,fbuf,tcp=0.0.0.0:5900,w=1024,h=768 \
-s 30,xhci,tablet \
-s 31,lpc -l com1,stdio \
-l bootrom,/usr/local/share/uefi-firmware/BHYVE_UEFI.fd \
debian
