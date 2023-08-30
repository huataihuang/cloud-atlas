.. _node_pressure_eviction:

=========================
节点压力驱逐
=========================

节点压力驱逐(node pressure eviction) 是 ``kubelet`` 主动终止Pod以回收节点上资源的过程。Kubelet监控集群节点的内存、磁盘空间和文件系统inode等资源，当这些资源的一个或多个达到特定消耗水平，kubelet可以主动使节点上的一个或多个Pod失效以回收资源。

kubelet 使用各种参数来做出驱逐决定：

- 驱逐信号
- 驱逐条件
- 监控间隔


参考
======

- `Kubernetes 文档 / 概念 / 调度、抢占和驱逐 / 节点压力驱逐 <https://kubernetes.io/zh-cn/docs/concepts/scheduling-eviction/node-pressure-eviction/>`_
- `Under Disk Pressure <https://neilcameronwhite.medium.com/under-disk-pressure-34b5ba4284b6>`_
