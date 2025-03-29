#!/bin/env bash

. /etc/profile

origin_vm="z-ubuntu20"
vm=$1
hosts_csv=/home/huatai/github.com/cloud-atlas/source/real/private_cloud/priv_cloud_infra/hosts.csv


function init {

     ip=`grep ",${vm}," $hosts_csv | awk -F, '{print $2}'`

     if [ -z $ip ]; then
         echo "You input vm name is invalid, can't find vm IP"
         echo "Please check $hosts_csv"
         exit 1
     fi
}

function clone_vm {
    virt-clone --original $origin_vm --name $vm --auto-clone
}

function customize_vm {

sudo guestfish -d "$vm" -i <<EOF
  write /etc/hostname "${vm}"

  download /etc/netplan/01-netcfg.yaml /tmp/01-netcfg.yaml
  ! sed -i "s/192.168.6.246/${ip}/g" /tmp/01-netcfg.yaml
  upload /tmp/01-netcfg.yaml /etc/netplan/01-netcfg.yaml

  download /etc/hosts /tmp/hosts
  ! sed -i '/z-ubuntu20/d' /tmp/hosts
  ! echo "${ip}  ${vm}.huatai.me  ${vm}" >> /tmp/hosts
  upload /tmp/hosts /etc/hosts
EOF

}

init
clone_vm
customize_vm
