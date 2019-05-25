.. _debug_node_notready:

=================================
kubenetes节点"NotReady"状态排查
=================================

在线上维护的Kubenetes的服务器节点(node)，最常见的问题是节点进入 ``NotReady`` 状态，这种情况是客户端异常，需要检查客户端日志。

排查
======

- 首先获取node节点报告，使用 ``describe nodes`` 可以看到详细信息::

   kubectl --kubeconfig ./biz/${CLUSTER}/admin.kubeconfig.yaml describe node 8183j73kx

在 ``Conditions:`` 段落可以获得初步的判断信息，例如::

   Conditions:
     Type             Status    LastHeartbeatTime                 LastTransitionTime                Reason              Message
     ----             ------    -----------------                 ------------------                ------              -------
     OutOfDisk        Unknown   Thu, 09 May 2019 07:44:16 +0800   Thu, 09 May 2019 07:45:00 +0800   NodeStatusUnknown   Kubelet stopped posting node status.
     MemoryPressure   Unknown   Thu, 09 May 2019 07:44:16 +0800   Thu, 09 May 2019 07:45:00 +0800   NodeStatusUnknown   Kubelet stopped posting node status.
     DiskPressure     Unknown   Thu, 09 May 2019 07:44:16 +0800   Thu, 09 May 2019 07:45:00 +0800   NodeStatusUnknown   Kubelet stopped posting node status.
     PIDPressure      Unknown   Thu, 09 May 2019 07:44:16 +0800   Thu, 09 May 2019 07:45:00 +0800   NodeStatusUnknown   Kubelet stopped posting node status.
     Ready            Unknown   Thu, 09 May 2019 07:44:16 +0800   Thu, 09 May 2019 07:45:00 +0800   NodeStatusUnknown   Kubelet stopped posting node status.

- 对于客户端 ``Kubelet`` 报错，如果可以登陆到客户机，则检查日志。需要注意日志是否通过 ``systemd`` 服务，如果是通过 journal 记录日志，则通过以下命令检查::

   journalctl -u kubelet

如果使用 syslog ，则直接检查服务日志。

参考
=======

- `How to debug when Kubernetes nodes are in 'Not Ready' state <https://stackoverflow.com/questions/47107117/how-to-debug-when-kubernetes-nodes-are-in-not-ready-state>`_
