cat << EOF > etcd_hosts
x-k3s-m-1
x-k3s-m-2
x-k3s-m-3
EOF

cat << EOF > prepare_etcd.sh
if [ -d /tmp/etcd_tls ];then
    rm -rf /tmp/etcd_tls
    mkdir /tmp/etcd_tls
else
    mkdir /tmp/etcd_tls
fi

if  [ ! -d /etc/etcd/ ];then
    sudo mkdir /etc/etcd
fi
EOF

for host in `cat etcd_hosts`;do
    scp prepare_etcd.sh $host:/tmp/
    ssh $host 'sh /tmp/prepare_etcd.sh'
done

for host in `cat etcd_hosts`;do
    scp ${host}.pem ${host}:/tmp/etcd_tls/
    scp ${host}-key.pem ${host}:/tmp/etcd_tls/
    scp ca.pem ${host}:/tmp/etcd_tls/
    scp server.pem ${host}:/tmp/etcd_tls/
    scp server-key.pem ${host}:/tmp/etcd_tls/
    scp client.csr ${host}:/tmp/etcd_tls/
    scp client.pem ${host}:/tmp/etcd_tls/
    scp client-key.pem ${host}:/tmp/etcd_tls/
    ssh $host 'sudo cp /tmp/etcd_tls/* /etc/etcd/;sudo chown etcd:etcd /etc/etcd/*'
done
