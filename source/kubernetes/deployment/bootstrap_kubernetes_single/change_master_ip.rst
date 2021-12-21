.. _change_master_ip:

============================
修改Kubernetes Master IP
============================

可能会遇到需要修改Kubernetes Mater IP地址的场景：

- 我在最初部署 :ref:`single_master_k8s` 时，由于GFW的存在，在安装部署Kubernetes集群时需要启动 :ref:`openconnect_vpn` ，但这带来一个问题：如果你是直接在Kubernetes节点上启用VPN，会导致增加了一个 ``tun0`` 网络接口，并且由于这个接口启用了默认路由，导致 ``kubeadm init`` 会将这个接口作为Kubernetes集群的control panel地址。

- 服务器搬迁或者云服务器采用动态IP地址分配，重启服务器后主机IIP变化。

Master IP变化的影响
====================

``/etc/kubenetes`` 目录下所有涉及接口IP的配置文件可以通过以下方式找出一一修订::

   cd /etc/kubernetes
   grep -R 192.168.101.81 *

但是，实际上 ``kubeadm init`` 签发的证书是包含服务器IP地址的，所以 ``kubectl`` 访问API服务器会提示错误::

   Unable to connect to the server: x509: certificate is valid for 10.96.0.1, 192.168.101.81, not 192.168.122.11

.. note::

   最好的初始化Kubernetes集群采用主机名方式，这样或许可以使得证书签发仅涉及主机名（域名），则可以方便后续调整master服务器IP地址。后续可以尝试验证。

修正Master IP
================

参考 `Changing master IP address <https://github.com/kubernetes/kubeadm/issues/338>`_ 中 valerius257 的解决方法::

   systemctl stop kubelet docker

   cd /etc/

   # backup old kubernetes data
   mv kubernetes kubernetes-backup
   mv /var/lib/kubelet /var/lib/kubelet-backup

   # restore certificates
   mkdir -p kubernetes
   cp -r kubernetes-backup/pki kubernetes
   rm kubernetes/pki/{apiserver.*,etcd/peer.*}

   systemctl start docker

   # reinit master with data in etcd
   # add --kubernetes-version, --pod-network-cidr and --token options if needed
   # 原文使用如下命令:
   # kubeadm init --ignore-preflight-errors=DirAvailable--var-lib-etcd
   # 但是由于我使用的是Flannel网络，所以一定要加上参数，否则后续安装 flannel addon无法启动pod
   kubeadm init --ignore-preflight-errors=DirAvailable--var-lib-etcd --pod-network-cidr=10.244.0.0/16

   # update kubectl config
   cp kubernetes/admin.conf ~/.kube/config

   # wait for some time and delete old node
   sleep 120
   kubectl get nodes --sort-by=.metadata.creationTimestamp
   kubectl delete node $(kubectl get nodes -o jsonpath='{.items[?(@.status.conditions[0].status=="Unknown")].metadata.name}')

   # check running pods
   kubectl get pods --all-namespaces

.. note::

   如果集群具有多个master节点，并且master IP地址转换是可控硅的，可以采用轮转替换master服务求来修订IP地址。即将新的Master加入集群，下线老的Master，逐步替换。

参考
======

- `Changing master IP address <https://github.com/kubernetes/kubeadm/issues/338>`_
