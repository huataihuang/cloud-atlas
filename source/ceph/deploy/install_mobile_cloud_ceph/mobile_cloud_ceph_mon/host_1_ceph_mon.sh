#!/usr/bin/env bash

function ceph_env() {
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

function create_ceph_mon_bootstrap_config() {
cat << EOF | sudo tee /etc/ceph/${CLUSTER}.conf
[global]
fsid = ${FSID}
mon initial members = ${HOST_1}
mon host = ${HOST_1_IP}
public network = ${HOST_NET}
auth cluster required = cephx
auth service required = cephx
auth client required = cephx
osd journal size = 1024
osd pool default size = 3
osd pool default min size = 2
osd pool default pg num = 128
osd pool default pgp num = 128
osd crush chooseleaf type = 1
EOF
}

function create_ceph_mon_keyring() {
    sudo ceph-authtool --create-keyring /tmp/${CLUSTER}.mon.keyring --gen-key -n mon. --cap mon 'allow *'
}

function create_ceph_client_admin_keyring() {
    sudo ceph-authtool --create-keyring /etc/ceph/${CLUSTER}.client.admin.keyring \
            --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' \
            --cap mds 'allow *' --cap mgr 'allow *'
}

function create_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        sudo mkdir -p $dir
        sudo chown ceph:ceph $dir
    fi
}

function create_ceph_bootstrap_osd_keyring() {
    create_dir /var/lib/ceph/bootstrap-osd
    sudo ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/${CLUSTER}.keyring \
        --gen-key -n client.bootstrap-osd \
        --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'
}

function add_key_to_mon_keyring() {
    sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/${CLUSTER}.client.admin.keyring
    sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/${CLUSTER}.keyring
    sudo chown ceph:ceph /tmp/ceph.mon.keyring
}

function create_monmap() {
    sudo -u ceph monmaptool --create --add ${HOST} ${HOST_IP} --fsid ${FSID} /tmp/monmap
}

function ceph_mon_mkfs() {
    create_dir /var/lib/ceph/mon/${CLUSTER}-${HOST}
    sudo -u ceph ceph-mon --cluster ${CLUSTER} --mkfs -i ${HOST} --monmap /tmp/monmap \
        --keyring /tmp/${CLUSTER}.mon.keyring
}

function default_ceph() {
    echo $CLUSTER | sudo tee /etc/default/ceph
}

function start_ceph() {
    sudo systemctl start ceph-mon@${HOST}
    sudo systemctl enable ceph-mon@${HOST}
}

ceph_env
create_ceph_mon_bootstrap_config
create_ceph_mon_keyring
create_ceph_client_admin_keyring
create_ceph_bootstrap_osd_keyring
add_key_to_mon_keyring
create_monmap
ceph_mon_mkfs
default_ceph
start_ceph
