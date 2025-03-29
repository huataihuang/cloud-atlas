HostName=$1
ZcloudIP=`cat /etc/hosts | grep zcloud-ip | awk '{print $1}'`

priv_cloud="/Users/huatai/github.com/cloud-atlas/source/real/priv_cloud/priv_cloud_infra/hosts.csv"

edge_cloud="/Users/huatai/github.com/cloud-atlas/source/real/edge_cloud/edge_cloud_infra/hosts.csv"

priv_ip_host=`cat $priv_cloud | grep ",$HostName," | awk -F, '{print $2","$3}'`
edge_ip_host=`cat $edge_cloud | grep ",$HostName," | awk -F, '{print $1","$2}'`

HostIP=`echo $priv_ip_host $edge_ip_host | grep $HostName | awk -F, '{print $1}'`

if [ -z $HostIP ]; then
    echo "Host $HostName not found"
else
    ssh -o "ProxyCommand ssh -W %h:%p $ZcloudIP" $HostIP
fi
