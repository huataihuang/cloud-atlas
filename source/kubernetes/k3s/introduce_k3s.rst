.. _introduce_k3s:

===================
K3s简介
===================

``k3s`` (5个字母) 和 :ref:`kubernetes` 的简称 ``k8s`` (10个字母) 相差一半字母，也契合了它的定义: 轻量级Kubernetes，硬件资源需求只是 ``k8s`` 的一半。

``k3s`` 易于安装，对硬件要求低(大约是 ``k8s`` 的一半内存，整个二进制程序小于100MB) ，主要适合以下应用场景:

- :ref:`edge_cloud`
- IoT ( :ref:`akraino` )
- CI ( :ref:`jenkins` )
- 开发环境
- :ref:`arm` 环境
- 嵌入式 ``k8s``
- 评估 ``k8s`` 

``k3s`` 从最初研发开始就致力于完全兼容Kubernetes发行版并提供以下增强:

- 使用单一二进制打包
- 默认使用 ``sqlite3`` 作为轻量级存储后端，并且提供 :ref:`etcd` , :ref:`mysql` , :ref:`pgsql` 作为可选项
- 使用一个简化的launcher来处理大量复杂的TLS以及选项
- 针对轻量级环境默认提供可靠的安全设置
- 简单但是提供了附加的 ``连干电池都包括`` 功能，例如: 本地存储提供(local storage provider)，负载均衡(service load balancer), Helm控制器, Trafik ingress控制器
- 所有kubernetes控制平面组件的操作被包装成一个单一二进制和进程，这样K3s可以自动化和管理复杂集群操作，例如分发证书
- 扩展依赖被最小化(只有一个现代化内核和cgroup挂载是必须的)，K3s软件包依赖包括:

  - :ref:`containerd`
  - :ref:`flannel`
  - :ref:`coredns`
  - :ref:`cni`
  - 主机工具(例如 :ref:`iptables` 和 :ref:`socat` )
  - Ingress控制器( :ref:`ingress_traefik` )
  - 内嵌服务负载均衡
  - 内嵌网络策略控制器

MicroK8s
============

Ubuntu也开发了一个轻量级的Kubernetes版本 `MicroK8s <https://microk8s.io>`_ 也是一个在小型低配置硬件上运行的Kubernetes版本，提供了较小的、快速和完全兼容Kubernetes的容器调度系统。MicroK8s也提供了离线安装的方法。

我可能在未来会做尝试。

参考
=====

- `Running K8s on ARM <https://www.nickaws.net/kubernetes/2020/03/20/Running-K8S-on-ARM.html>`_
- `k3s官网 <https://k3s.io>`_
