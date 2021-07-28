.. _delete_kubeadm_cluster:

=================================
删除kubeadm构建的Kubernetes集群
=================================

所有通过 :ref:`kubeadmn` 工具构建的Kubernetes集群以及节点，都可以通过 ``kubeadm`` 工具反向卸载(删除)，这是一个非常方便的操作。我的实践是因为在开发测试环境， :ref:`upgrade_kubeadm_cluster` 失败，为了快速开始下一阶段测试工作，所以准备重建Kubernetes集群。

- ``kubeadm reset`` 命令执行会提示::

   [reset] WARNING: Changes made to this host by 'kubeadm init' or 'kubeadm join' will be reverted.
   [reset] Are you sure you want to proceed? [y/N]:

也就是说，不管是加入集群的工作节点，还是初始化的管控节点，都可以用这个工具反向操作

- 检查集群::

   kubectl get nodes

当前节点::

   NAME         STATUS   ROLES    AGE    VERSION
   pi-master1   Ready    master   241d   v1.20.9
   pi-worker1   Ready    <none>   237d   v1.20.9
   pi-worker2   Ready    <none>   237d   v1.21.3
   zcloud       Ready    <none>   127d   v1.21.3

- 首先在 ``zcloud`` 上执行节点清理::

   kubeadm reset
   [reset] WARNING: Changes made to this host by 'kubeadm init' or 'kubeadm join' will be reverted.
   [reset] Are you sure you want to proceed? [y/N]: y

提示信息::

   [preflight] Running pre-flight checks
   W0728 23:50:09.914348 3734557 removeetcdmember.go:79] [reset] No kubeadm config, using etcd pod spec to get data directory
   [reset] No etcd config found. Assuming external etcd
   [reset] Please, manually reset etcd to prevent further issues
   [reset] Stopping the kubelet service
   [reset] Unmounting mounted directories in "/var/lib/kubelet"
   [reset] Deleting contents of config directories: [/etc/kubernetes/manifests /etc/kubernetes/pki]
   [reset] Deleting files: [/etc/kubernetes/admin.conf /etc/kubernetes/kubelet.conf /etc/kubernetes/bootstrap-kubelet.conf /etc/kubernetes/controller-manager.conf /etc/kubernetes/scheduler.conf]
   [reset] Deleting contents of stateful directories: [/var/lib/kubelet /var/lib/dockershim /var/run/kubernetes /var/lib/cni]

   The reset process does not clean CNI configuration. To do so, you must remove /etc/cni/net.d

   The reset process does not reset or clean up iptables rules or IPVS tables.
   If you wish to reset iptables, you must do so manually by using the "iptables" command.

   If your cluster was setup to utilize IPVS, run ipvsadm --clear (or similar)
   to reset your system's IPVS tables.

   The reset process does not clean your kubeconfig files and you must remove them manually.
   Please, check the contents of the $HOME/.kube/config file.

可以看到 ``reset`` 过程不会清理CNI配置，也不会清理iptables规则，两者需要手工处理

- 完成以后，在管控服务器上检查，可以看到该工作节点已经 ``NotReady`` ::

   kubectl get nodes

显示::

   NAME         STATUS     ROLES    AGE    VERSION
   pi-master1   Ready      master   241d   v1.20.9
   pi-worker1   Ready      <none>   237d   v1.20.9
   pi-worker2   Ready      <none>   237d   v1.21.3
   zcloud       NotReady   <none>   127d   v1.21.3

- 删除节点::

   kubectl delete node zcloud

- 在工作节点上再执行一次清理 ``iptables`` 和 ``cni`` ::

   rm -rf /etc/cni/net.d
   iptables -F

- 所有工作节点清理以后，最后执行管控节点卸载::

   kubeadm reset

输出信息::

   [preflight] Running pre-flight checks
   [reset] Removing info for node "pi-master1" from the ConfigMap "kubeadm-config" in the "kube-system" Namespace
   W0729 00:23:55.555252 3406560 removeetcdmember.go:61] [reset] failed to remove etcd member: error syncing endpoints with etcd: context deadline exceeded, please manually remove this etcd member using etcdctl
   [reset] Stopping the kubelet service
   [reset] Unmounting mounted directories in "/var/lib/kubelet"
   [reset] Deleting contents of config directories: [/etc/kubernetes/manifests /etc/kubernetes/pki]
   [reset] Deleting files: [/etc/kubernetes/admin.conf /etc/kubernetes/kubelet.conf /etc/kubernetes/bootstrap-kubelet.conf /etc/kubernetes/controller-manager.conf /etc/kubernetes/scheduler.conf]
   [reset] Deleting contents of stateful directories: [/var/lib/etcd /var/lib/kubelet /var/lib/dockershim /var/run/kubernetes /var/lib/cni]

   The reset process does not clean CNI configuration. To do so, you must remove /etc/cni/net.d

   The reset process does not reset or clean up iptables rules or IPVS tables.
   If you wish to reset iptables, you must do so manually by using the "iptables" command.

   If your cluster was setup to utilize IPVS, run ipvsadm --clear (or similar)
   to reset your system's IPVS tables.

   The reset process does not clean your kubeconfig files and you must remove them manually.
   Please, check the contents of the $HOME/.kube/config file.

- 清理完好干净::

   root@pi-master1:~# docker ps
   CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
   root@pi-master1:~# docker ps --all
   CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

参考
=====

- `How to completely uninstall kubernetes <https://stackoverflow.com/questions/44698283/how-to-completely-uninstall-kubernetes>`_
