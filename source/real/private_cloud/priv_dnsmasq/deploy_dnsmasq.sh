#!/bin/env bash

. /etc/profile

hosts_csv=/home/huatai/github.com/cloud-atlas/source/real/private_cloud/priv_cloud_infra/hosts.csv

function init {
    cat /home/huatai/github.com/cloud-atlas/source/real/private_cloud/priv_cloud_infra/hosts.csv | grep -v "主机" | awk -F, '{print $2"  "$3}' > /tmp/hosts
}

function cp_hosts {
    sudo cp /tmp/hosts /etc/hosts
}

function restart_dnsmasq {
    sudo systemctl restart dnsmasq
}

init
cp_hosts
restart_dnsmasq
