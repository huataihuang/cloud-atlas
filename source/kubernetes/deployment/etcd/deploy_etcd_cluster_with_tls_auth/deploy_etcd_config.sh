cat << EOF > etcd_hosts
x-k3s-m-1
x-k3s-m-2
x-k3s-m-3
EOF

cat << EOF > prepare_etcd_config.sh
if [ -d /tmp/etcd_config ];then
    rm -rf /tmp/etcd_config
    mkdir /tmp/etcd_config
else
    mkdir /tmp/etcd_config
fi

if  [ ! -d /etc/etcd/ ];then
    sudo mkdir /etc/etcd
fi
EOF

for host in `cat etcd_hosts`;do
    scp prepare_etcd_config.sh $host:/tmp/
    ssh $host 'sh /tmp/prepare_etcd_config.sh'
done

for host in `cat etcd_hosts`;do
    scp config_etcd.sh $host:/tmp/etcd_config/
    scp conf.yml $host:/tmp/etcd_config/
    ssh $host 'sh /tmp/etcd_config/config_etcd.sh'
    ssh $host 'sudo cp /tmp/etcd_config/conf.yml /etc/etcd/'
done
