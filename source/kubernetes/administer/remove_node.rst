.. _remove_node:

=========================
从Kubernetes集群删除节点
=========================

在 :ref:`arm_k8s_deploy` 我在3个worker节点上部署了 ``replicas: 3`` 的 ``name: kube-verify`` 的 ``Deployment`` ，所以，我们会看到有3个pod，分别运行在3个worker节点上::

   kubectl -n kube-verify get pods -o wide

显示::

   NAME                           READY   STATUS    RESTARTS   AGE   IP           NODE         NOMINATED NODE   READINESS GATES
   kube-verify-69dd569645-nvnhl   1/1     Running   0          23h   10.244.3.2   jetson       <none>           <none>
   kube-verify-69dd569645-s5qb5   1/1     Running   0          23h   10.244.2.2   pi-worker2   <none>           <none>
   kube-verify-69dd569645-v9zxt   1/1     Running   0          23h   10.244.1.2   pi-worker1   <none>           <none>

我们需要将节点 ``jetson`` 安全删除并重新加入，所以请参考 :ref:`remove_node` 执行操作:

删除 ``jeson`` 节点
=====================

.. note::

   所谓删除节点，首先需要清空节点上所有业务pod。这个清理pod通常不需要包含daemonset(和节点相关的运维辅助pods)，所以使用参数 ``--ignore-daemonsets`` 。

由于jetson节点挂掉了，所以首先通过 ``kubectl get nodes`` 看到节点是 ``NotReady`` 状态::

   NAME         STATUS     ROLES    AGE    VERSION
   jetson       NotReady   <none>   104d   v1.20.2
   ...

- 关闭节点调度(cordon)::

   kubectl cordon jetson

.. note::

   关闭调度可以通过标签过滤选择，使用参数 ``-l, --selector=""``

关闭节点调度以后，再次使用 ``kubectl get nodes`` 检查节点状态如下::

   NAME         STATUS                        ROLES    AGE    VERSION
   jetson       NotReady,SchedulingDisabled   <none>   104d   v1.20.2
   ...

- 清空( :ref:`drain_node` )节点(注意，这个步骤仅在节点 ``Ready`` 状态下才需要执行，如果节点已经 ``NotReady`` 了，则 ``drain`` 命令会卡住无法完成)::

   kubectl drain jetson --delete-local-data --force --ignore-daemonsets

.. note::

   现在 ``--delete-local-data`` 参数已经废弃，改为使用 ``--delete-emptydir-data``

这里只要 ``drain`` 没有报错返回就表明节点已经清理干净。

此时检查节点 ``kubectl get nodes -o wide`` 会看到节点状态是 ``SchedulingDisabled`` ::

   NAME         STATUS                     ROLES    AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
   jetson       Ready,SchedulingDisabled   <none>   56m     v1.19.4   192.168.6.10   <none>        Ubuntu 18.04.5 LTS   4.9.140-tegra      docker://19.3.6
   pi-master1   Ready                      master   7d1h    v1.19.4   192.168.6.11   <none>        Ubuntu 20.04.1 LTS   5.4.0-1022-raspi   docker://19.3.8
   pi-worker1   Ready                      <none>   3d13h   v1.19.4   192.168.6.15   <none>        Ubuntu 20.04.1 LTS   5.4.0-1022-raspi   docker://19.3.8
   pi-worker2   Ready                      <none>   3d13h   v1.19.4   192.168.6.16   <none>        Ubuntu 20.04.1 LTS   5.4.0-1022-raspi   docker://19.3.8

不过实际上，我发现 ``kubectl drain`` 并没有清理掉jetson节点上的 ``cni0`` ，使用 ``ifconfig`` 依然会看到::

   cni0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
          inet 10.244.3.1  netmask 255.255.255.0  broadcast 10.244.3.255
          inet6 fe80::d476:bff:fe23:b011  prefixlen 64  scopeid 0x20<link>
          ether d6:76:0b:23:b0:11  txqueuelen 1000  (Ethernet)
          RX packets 160  bytes 4480 (4.4 KB)
          RX errors 0  dropped 0  overruns 0  frame 0
          TX packets 412  bytes 39406 (39.4 KB)
          TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

这导致节点再次加入时候会出现无法分配 ``cni0`` 的IP地址。所以我这里手工做了清理::

   ip link delete cni0      

注意，如果确实修复好节点，可以恢复节点调度::

   kubectl uncordon jetson

- 再次执行检查pods::

   kubectl -n kube-verify get pods -o wide

- 可以看到当前运行的pod被驱逐(evict)到其他节点上(这里是 ``kube-verify-69dd569645-nvnhl`` 被驱逐改到 ``pi-worker2`` 节点上的 ``kube-verify-69dd569645-9msjb`` )::

   NAME                           READY   STATUS    RESTARTS   AGE   IP           NODE         NOMINATED NODE   READINESS GATES
   kube-verify-69dd569645-9msjb   1/1     Running   0          39s   10.244.2.3   pi-worker2   <none>           <none>
   kube-verify-69dd569645-s5qb5   1/1     Running   0          24h   10.244.2.2   pi-worker2   <none>           <none>
   kube-verify-69dd569645-v9zxt   1/1     Running   0          24h   10.244.1.2   pi-worker1   <none>           <none>

.. note::

   如果jetson节点是意外故障，则会看到新的容器已经调度到其他节点上，但是 jetson节点上容器一直处于 ``Terminating`` 状态无法结束。不过没有关系，后面直接执行 ``kubectl delete node jetson`` 会清理掉残留pod信息。

- 如果检查所有namespaces，可以看到 jetson 节点只剩下一些系统pods，这样我们就能够安全删除该节点(没有业务pods)::

   kubectl get pods --all-namespaces -o wide | grep jetson

输出类似(如果节点jetson是 ``Ready`` 正常状态，则会看到类似如下输出)::

   kube-system   kube-flannel-ds-arm64-z544l          1/1     Running   0          25h     30.73.166.34   jetson       <none>           <none>
   kube-system   kube-flannel-ds-twhgk                1/1     Running   0          25h     30.73.166.34   jetson       <none>           <none>
   kube-system   kube-proxy-49qlz                     1/1     Running   0          25h     30.73.166.34   jetson       <none>           <none>

- 删除(delete node)::

   kubectl delete node jetson

然后验证确保节点已经删除::

   kubectl get nodes

.. note::

   假设我们修复好了jetson节点故障，需要重新将节点加入回集群。

   如果是重新安装系统修复jetson节点，则参考 :ref:`arm_k8s_deploy` 重新添加修复节点。

- 登陆jetson节点，重新执行加入jetson节点::

   kubeadm join 192.168.6.11:6443 --token <TOKEN> \
       --discovery-token-ca-cert-hash sha256:<HASH_TOKEN>

这里会报错显示已经存在配置::

   W1206 23:35:48.174471   12598 join.go:377] [preflight] WARNING: --control-plane is also required when passing control-plane related flags such as [certificate-key, apiserver-advertise-address, apiserver-bind-port]
   [preflight] Running pre-flight checks
   error execution phase preflight: [preflight] Some fatal errors occurred:
   	[ERROR FileAvailable--etc-kubernetes-kubelet.conf]: /etc/kubernetes/kubelet.conf already exists
   	[ERROR Port-10250]: Port 10250 is in use
   	[ERROR FileAvailable--etc-kubernetes-pki-ca.crt]: /etc/kubernetes/pki/ca.crt already exists
   [preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
   To see the stack trace of this error execute with --v=5 or higher

这是因为遗漏了清理 jetson 节点的步骤，所以补上操作::

   kubeadm reset

提示信息::

   [reset] WARNING: Changes made to this host by 'kubeadm init' or 'kubeadm join' will be reverted.
   [reset] Are you sure you want to proceed? [y/N]:

输入 ``y`` 确认机会执行本地节点清理工作。

- 上述reset指令并不重置或清理iptables规则或IPVS表，如果要reset iptables，则需要手工执行::

   iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X

- 注意，如果集群设置使用了 ``IPVS`` 则还需要执行 ``ipvsadm --clear`` ::

   ipvsadm -C

- 完成清理节点之后，再次执行节点加入就可以成功::

   kubeadm join 192.168.6.11:6443 --token <TOKEN> \
       --discovery-token-ca-cert-hash sha256:<HASH_TOKEN>

参考
=======

- `How to remove broken nodes in Kubernetes <https://stackoverflow.com/questions/56064537/how-to-remove-broken-nodes-in-kubernetes/56289161>`_
- `Remove a Kubernetes Node <https://docs.mirantis.com/mcp/q4-18/mcp-operations-guide/kubernetes-operations/k8s-node-ops/k8s-node-remove.html>`_
- `Safely Drain a Node <https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/>`_
- `Remove a Kubernetes Node <https://docs.mirantis.com/mcp/q4-18/mcp-operations-guide/kubernetes-operations/k8s-node-ops/k8s-node-remove.html>`_
