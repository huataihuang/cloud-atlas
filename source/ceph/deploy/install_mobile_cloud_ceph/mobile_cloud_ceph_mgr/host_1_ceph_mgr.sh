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

create_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        sudo mkdir -p $dir
        sudo chown ceph:ceph $dir
    fi
}

create_ceph_mgr_keyring() {
    create_dir /var/lib/ceph/mgr/${CLUSTER}-${HOST}
    sudo ceph auth get-or-create mgr.${HOST} mon 'allow profile mgr' osd 'allow *' mds 'allow *' \
            | sudo tee /var/lib/ceph/mgr/${CLUSTER}-${HOST}/keyring

    sudo chown ceph:ceph /var/lib/ceph/mgr/${CLUSTER}-${HOST}/keyring
    sudo chmod 600 /var/lib/ceph/mgr/${CLUSTER}-${HOST}/keyring
}

start_ceph_mgr() {
    sudo systemctl start ceph-mgr@${HOST}
    sudo systemctl enable ceph-mgr@${HOST}
}

install_ceph_mgr_dashboard() {
    if ! rpm -qa | grep ceph-mgr-dashboard; then
        sudo dnf install -y ceph-mgr-dashboard
    else
        echo "ceph-mgr-dashboard has installed"
    fi
}

enable_ceph_mgr_dashboard() {
    sudo ceph mgr module enable dashbard -c /etc/ceph/${CLUSTER}.conf

    openssl req -new -nodes -x509 \
        -subj "/O=IT/CN=ceph-mgr-dashboard" -days 3650 \
        -keyout dashboard.key -out dashboard.crt -extensions v3_ca

    sudo ceph dashboard set-ssl-certificate -i dashboard.crt -c /etc/ceph/${CLUSTER}.conf
    sudo ceph dashboard set-ssl-certificate-key -i dashboard.key -c /etc/ceph/${CLUSTER}.conf

    # 创建登陆账号admin，密保保存在 pw.txt 文件中
    sudo ceph dashboard ac-user-create admin -i pw.txt administrator

    echo "ceph dashboard URL:"
    sudo ceph mgr services -c /etc/ceph/${CLUSTER}.conf
}

ceph_env
create_ceph_mgr_keyring
start_ceph_mgr
install_ceph_mgr_dashboard
enable_ceph_mgr_dashboard
