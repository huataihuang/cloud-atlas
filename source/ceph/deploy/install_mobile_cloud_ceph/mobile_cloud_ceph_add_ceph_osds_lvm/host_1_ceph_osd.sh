#!/usr/bin/env bash

ceph_env() {
    CLUSTER=ceph
    # FSID=$(cat /proc/sys/kernel/random/uuid)
    FSID=598dc69c-5b43-4a3b-91b8-f36fc403bcc5

    HOST=$(hostname -s)
    HOST_IP=$(hostname -i)

    HOST_1=a-b-data-1
    HOST_2=a-b-data-2
    HOST_3=a-b-data-3

    HOST_1_IP=192.168.8.204
    HOST_2_IP=192.168.8.205
    HOST_3_IP=192.168.8.206

    HOST_NET=192.168.8.0/24
}

parted_vbd() {
    sudo parted /dev/vdb mklabel gpt
    sudo parted -a optimal /dev/vdb mkpart primary 0% 50G
}

create_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        sudo mkdir -p $dir
        sudo chown ceph:ceph $dir
    fi
}

create_ceph_osd() {
    create_dir /var/lib/ceph/osd/ceph-0
    sudo ceph-volume lvm create --bluestore --data /dev/vdb1

    sleep 1

    echo "ceph-volume:"
    sudo ceph-volume lvm list
}

ceph_env
parted_vbd
create_ceph_osd
