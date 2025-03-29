NODENAME=`hostname -s`
NODEIP=`ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1`
NODE1="x-k3s-m-1"
NODE2="x-k3s-m-2"
NODE3="x-k3s-m-3"
DOMAIN="edge.huatai.me"
INITTOKEN="x-k3s"

cd /tmp/etcd_config
sed -i "s/NODENAME/$NODENAME/g" conf.yml
sed -i "s/NODEIP/$NODEIP/g" conf.yml
sed -i "s/INITTOKEN/$INITTOKEN/g" conf.yml
sed -i "s/NODE1/$NODE1/g" conf.yml
sed -i "s/NODE2/$NODE2/g" conf.yml
sed -i "s/NODE3/$NODE3/g" conf.yml
sed -i "s/DOMAIN/$DOMAIN/g" conf.yml
