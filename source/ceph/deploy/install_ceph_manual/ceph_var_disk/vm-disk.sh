#!/bin/env bash

. /etc/profile

vm=$1
suffix=ceph #表示磁盘用途
disk_size=2G

function init {

    if [ ! -f vm-disk.xml ]; then

cat > vm-disk.xml <<__XML__
<disk type='block' device='disk'>
  <driver name='qemu' type='raw' cache='none' io='native'/>
  <source dev='/dev/vg-libvirt/VM_SUFFIX' index='1'/>
  <backingStore/>
  <target dev='vdb' bus='virtio'/>
  <alias name='virtio-disk1'/>
</disk>
__XML__

    fi

    vm_disk=`sudo lvs | grep -v "LV" | awk '{print $1}' | grep "^${vm}_${suffix}$"`
    if [ -z ${vm_disk} ]; then
        virsh vol-create-as images_lvm ${vm}_${suffix} ${disk_size}
    else
        echo "${vm}_${suffix} already exist!"
    fi
}

function inject_vm_disk {
    cat vm-disk.xml | sed "s/VM/${vm}/g" | sed "s/SUFFIX/${suffix}/g" > ${vm}-disk.xml
    virsh attach-device ${vm} ${vm}-disk.xml --live --config
}

init
inject_vm_disk
