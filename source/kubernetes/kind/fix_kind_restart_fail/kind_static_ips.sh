#!/usr/bin/env bash
set -e

CLUSTER_NAME='dev'
reg_name="${CLUSTER_NAME}-registry"

# Workaround for https://github.com/kubernetes-sigs/kind/issues/2045
# all_nodes=$(kind get nodes --name "${CLUSTER_NAME}" | tr "\n" " ")
# 我将 registry 也加入了列表指定静态IP
all_nodes=$(kind get nodes --name "${CLUSTER_NAME}" | tr "\n" " ")${reg_name}
declare -A nodes_table
ip_template="{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}"

echo "Saving original IPs from nodes"

for node in ${all_nodes}; do
  #nodes_table["${node}"]=$(docker inspect -f "${ip_template}" "${node}")
  #registry有2个网络接口，这里采用了一个比较ugly的方法，过滤掉不属于kind网络的接口IP
  nodes_table["${node}"]=$(docker inspect -f "${ip_template}" "${node}" | sed 's/172.17.0.2//')
  echo "${node}: ${nodes_table["${node}"]}"
done

echo "Stopping all nodes and registry"
docker stop ${all_nodes} >/dev/null

echo "Re-creating network with user defined subnet"
subnet=$(docker network inspect -f "{{(index .IPAM.Config 0).Subnet}}" "kind")
echo "Subnet: ${subnet}"
gateway=$(docker network inspect -f "{{(index .IPAM.Config 0).Gateway}}" "kind")
echo "Gateway: ${gateway}"
docker network rm "kind" >/dev/null
docker network create --driver bridge --subnet ${subnet} --gateway ${gateway} "kind" >/dev/null

echo "Assigning static IPs to nodes"
for node in "${!nodes_table[@]}"; do
  docker network connect --ip ${nodes_table["${node}"]} "kind" "${node}"
  echo "Assigning IP ${nodes_table["${node}"]} to node ${node}"
done

echo "Starting all nodes and registry"
docker start ${all_nodes} >/dev/null

echo -n "Wait until all nodes are ready "

while :; do
  #[[ $(kubectl get nodes | grep Ready | wc -l) -eq ${#nodes_table[@]} ]] && break
  #需要启动的k8s节点比docker的容器列表少2 (registry和haproxy没有包含在k8s)
  pod_num=`expr ${#nodes_table[@]} - 2`
  [[ $(kubectl get nodes | grep Ready | wc -l) -eq ${pod_num} ]] && break
  echo -n "."
  sleep 5
done

echo
