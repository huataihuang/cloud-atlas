#!/bin/env bash

. /etc/profile

vm=$1
suffix=docker #表示磁盘用途
rbd_pool="libvirt-pool"
hosts_csv=/home/huatai/github.com/cloud-atlas/source/real/private_cloud/priv_cloud_infra/hosts.csv


function init {

    if [ ! -f docker-disk.xml ]; then

cat > ${suffix}-disk.xml <<__XML__
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
  <target dev='vdb' bus='virtio'/>
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

function inject_vm_disk {
    virsh vol-create-as --pool images_rbd --name ${vm}.${suffix} --capacity 10GB --allocation 10GB --format raw
    cat ${suffix}-disk.xml | sed "s/RBD_DISK/${vm}.${suffix}/g" > ${vm}.${suffix}-disk.xml
    virsh attach-device $vm ${vm}.${suffix}-disk.xml --live --config
}

init
inject_vm_disk
