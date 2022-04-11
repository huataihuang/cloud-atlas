cat << EOF > etcd_hosts
x-k3s-m-1
x-k3s-m-2
x-k3s-m-3
EOF

cat << EOF > prepare_etcd_service.sh
if [ -d /tmp/etcd_service ];then
    rm -rf /tmp/etcd_service
    mkdir /tmp/etcd_service
else
    mkdir /tmp/etcd_service
fi
EOF

for host in `cat etcd_hosts`;do
    scp prepare_etcd_service.sh $host:/tmp/
    ssh $host 'sh /tmp/prepare_etcd_service.sh'
done

for host in `cat etcd_hosts`;do
    scp conf.d-etcd $host:/tmp/etcd_service/
    scp init.d-etcd $host:/tmp/etcd_service/
    ssh $host 'sudo cp /tmp/etcd_service/conf.d-etcd /etc/conf.d/etcd'
    ssh $host 'sudo cp /tmp/etcd_service/init.d-etcd /etc/init.d/etcd'
    ssh $host 'sudo addgroup -g 1001 etcd && sudo adduser -u 1001 -G etcd -h /dev/null -s /sbin/nologin -D etcd'
done
