.. _daemonset:

===============
DaemonSet
===============

DaemonSet是指在每个节点上运行一个Pod实例，并且每个节点只运行一个Pod实例的部署模式。这就相当于服务器Host操作系统中的一个daemon服务(如每个服务器上通常都会运行sshd服务一样)，当新节点加入集群，这个节点上就会相应部署一个daemonset；反之，当节点从集群移除，则该daemonset也会回收。

.. note::

   和 :ref:`replicaset` 不同， ReplicaSet是确保集群中存在指定数量的pod副本，而DaemonSet则是确保每个节点上运行一个pod副本。所以，当节点从集群中删除时，不会再其他地方重新创建DaemonSet pod。

.. note::

   设置了不可调度属性的节点依然会部署DaemonSet，因为DaemonSet管理的pod完全绕过调度器。DaemonSet目的是运行系统服务，所以即使在不可调度的节点上，系统服务通常也需要运行。

删除DaemonSet将删除它所创建的所有Pod。

DaemonSet通常用于部署：

- 在每个节点上运行集群存储DaemonSet，如 :ref:`glusterd` :ref:`ceph`
- 在每个节点上运行日志采集DaemonSet，如 :ref:`fluentd` :ref:`logstash`
- 在每个节点上运行监控DaemonSet，如 :ref:`prometheus_node_exporter` :ref:`collectd` 以及各种Agent
- 在每个节点上运行Kubernetes自己的DaemonSet，如 kube-proxy

简单的部署方式是在所有节点上启动相同配置的DaemonSet，不区分硬件类型。较为复杂一些的配置是结合标签对不同硬件(例如GPU设备，SSD存储硬件)使用不同DaemonSet。



参考
======

- `Kubernetes官方文档 DaemonSet <https://kubernetes.io/zh/docs/concepts/workloads/controllers/daemonset/>`_
