.. _drain_node:

============================
安全地清空一个Kubernetes节点
============================

当我们需要下线一个Kubernetes节点前，我们需要先把节点上的pods都驱逐 ``evict`` 出去。Kubernetes提供了一个简单的不需要指定pods的驱逐方法，就是 ``drain`` 节点。

- 举例，我们清空节点 ``jetson`` ::

   kubectl drain jetson --delete-local-data --force --ignore-daemonsets

此时会提示::

   node/jetson cordoned
   WARNING: ignoring DaemonSet-managed Pods: kube-system/kube-flannel-ds-arm64-f6z9b, kube-system/kube-flannel-ds-rxw88, kube-system/kube-proxy-8lclg
   evicting pod kube-verify/kube-verify-69dd569645-q24vf
   pod/kube-verify-69dd569645-q24vf evicted
   node/jetson evicted

恢复drain节点
================

如果Kubernetes节点已经修复完成，确定节点可以恢复调度，则执行 ``kubectl uncordon`` 来恢复节点(这个指令实际上是常用的 ``kubectl cordon`` 的逆反)::

   kubectl uncordon jetson

此时会看到输出::

   node/jetson uncordoned

再次检查节点 ``kubectl get nodes -o wide`` 会看到jetson节点恢复调度::

   NAME         STATUS   ROLES    AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
   jetson       Ready    <none>   59m     v1.19.4   192.168.6.10   <none>        Ubuntu 18.04.5 LTS   4.9.140-tegra      docker://19.3.6

参考
======

- `Safely Drain a Node <https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/>`_
