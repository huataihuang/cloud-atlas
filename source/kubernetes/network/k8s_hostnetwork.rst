.. _k8s_hostnetwork:

=======================
Kubernetes hostNetwork
=======================

在 :ref:`z-k8s_gpu_prometheus_grafana` 排查 :ref:`calico` 网络异常的 :ref:`daemonset` 无法访问的问题，最终采用 :ref:`kube-prometheus-stack_hostnetwork` 来规避。这种 ``hostNetwork`` 虽然不是 :ref:`k8s_network` CNI解决方案，但是对于 ``Nodes`` 运维会有很大帮助，因为pod完全是类似物理主机上的 :ref:`systemd` 服务来工作，所以只要物理主机工作正常， ``daemonset`` 就能够正常工作。

当服务器上的 :ref:`k8s_network` 无法正常工作时，使用 ``spec.hostNetwork: true`` 的pods依然可以和外部通讯( 需要配置 ``node.kubernetes.io/network-unavailable`` 容忍度 )，这对系统进行异常处理故障恢复会有很大帮助，也是基础系统运维的利器。

参考
======

- `Kubenet network performance degraded, solved using hostNetwork: true, with unicorn app <https://discuss.kubernetes.io/t/kubenet-network-performance-degraded-solved-using-hostnetwork-true-with-unicorn-app/2874>`_ 通过 ``hostnetwork`` 解决网络性能降级问题

  - `DNS intermittent delays of 5s #56903 <https://github.com/kubernetes/kubernetes/issues/56903>`_ 案例，weave CNI网络有一个DNS查询策略在不同的内核和glibc下可能有不同表现，使用 ``dnsPolicy: Default`` 可能会缓解 。详细分析见 `Racy conntrack and DNS lookup timeouts <https://www.weave.works/blog/racy-conntrack-and-dns-lookup-timeouts>`_ (weaveworks官方博客) : DNS查询是通过DNAT(Destination Network Address Translation)在内核实现 ;  `5 – 15s DNS lookups on Kubernetes?  <https://blog.quentin-machu.fr/2018/06/24/5-15s-dns-lookups-on-kubernetes/>`_

- `Kubernetes 文档/概念/工作负载/工作负载资源/DaemonSet <https://kubernetes.io/zh-cn/docs/concepts/workloads/controllers/daemonset/>`_
