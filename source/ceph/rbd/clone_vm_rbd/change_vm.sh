#!/bin/env bash

. /etc/profile

origin_vm="z-ubuntu20-rbd"
vm=$1
rbd_pool="libvirt-pool"
hosts_csv=/home/huatai/github.com/cloud-atlas/source/real/private_cloud/priv_cloud_infra/hosts.csv


function init {

    if [ ! -f new-rbd.xml ]; then

cat > new-rbd.xml <<__XML__
<disk type='network' device='disk'>
  <driver name='qemu' type='raw' cache='none' io='native'/>
  <auth username='libvirt'>
    <secret type='ceph' uuid='3f203352-fcfc-4329-b870-34783e13493a'/>
  </auth>
  <source protocol='rbd' name='libvirt-pool/RBD_DISK'>
    <host name='192.168.6.204' port='6789'/>
    <host name='192.168.6.205' port='6789'/>
    <host name='192.168.6.206' port='6789'/>
  </source>
  <target dev='vda' bus='virtio'/>
  <address type='pci' domain='0x0000' bus='0x03' slot='0x00' function='0x0'/>
</disk>
__XML__

     fi

     ip=`grep ",${vm}," $hosts_csv | awk -F, '{print $2}'`

     if [ -z $ip ]; then
         echo "You input vm name is invalid, can't find vm IP"
         echo "Please check $hosts_csv"
         exit 1
     fi
}

function clone_vm {
    virt-clone --original $origin_vm --name $vm --auto-clone
    sudo rbd cp ${rbd_pool}/${origin_vm} ${rbd_pool}/${vm}
    cat new-rbd.xml | sed "s/RBD_DISK/${vm}/g" > ${vm}-disk.xml
    virsh attach-device $vm ${vm}-disk.xml --config
}

function customize_vm {

sudo guestfish -d "$vm" -i <<EOF
  write /etc/hostname "${vm}"

  download /etc/netplan/01-netcfg.yaml /tmp/01-netcfg.yaml
  ! sed -i "s/192.168.6.247/${ip}/g" /tmp/01-netcfg.yaml
  upload /tmp/01-netcfg.yaml /etc/netplan/01-netcfg.yaml

  download /etc/hosts /tmp/hosts
  ! sed -i '/z-ubuntu-rbd/d' /tmp/hosts
  ! echo "${ip}  ${vm}.huatai.me  ${vm}" >> /tmp/hosts
  upload /tmp/hosts /etc/hosts
EOF

}

init
clone_vm
customize_vm
