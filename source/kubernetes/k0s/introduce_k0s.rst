.. _introduce_k0s:

========================
k0s简介
========================

我是2024年底才关注到 ``k0s`` ，原因还是因为我准备重新部署和学习 :ref:`k3s` 偶然发现，原来在2020年6月新诞生的 `k0sproject.io <https://k0sproject.io>`_ 是类似于 :ref:`k3s` 但是侧重点有所不同的轻量级 :ref:`kubernetes` 发行版。

`k0sproject.io <https://k0sproject.io>`_ 是 :ref:`mirantis` 开发的Kubernetes定制版本，和标准Kubernetes主要区别是:

- 使用单一的二进制执行代码发布，除了主机操作系统内核外没有任何依赖：无需而外软件包或配置，简化运行
- 基于100%上游Kubernetes且经过认证(也就是说兼容k8s，类似 :ref:`k3s` 一样对k8s进行裁剪)
- 使用 ``k0sctl`` 进行管理: 升级、备份和恢复
- 对硬件系统要求低: 1 vCPU, 1GB RAM
- 默认使用控制平面隔离(也就是管控服务器和工作节点分开角色)，可以从单一节点扩展到大型高可用集群
- 支持自定义容器网络接口(CNI)插件，默认使用 ``Kube-Router`` ，可选预配置的 :ref:`calico` 
- 支持多种数据存储后端: 

  - 多节点默认使用 :ref:`etcd`
  - 通过 :ref:`kine` 切换不同后端:

    - 单节点默认使用 :ref:`sqlite`
    - 多节点可选使用 :ref:`mysql` 或 :ref:`pgsql`

- 支持 x86-64, ARM64 和 ARMv7
- 内置包含了 :ref:`konnectivity` :ref:`coredns` 和 :ref:`metrics-server`

.. note::

   我计划在 :ref:`edge_cloud_infra_2024` 的 ``bcloud`` :ref:`pi_cluster` 部署 ``k0s`` ，以便和 :ref:`k3s` 进行对比实践。

.. _mirantis:

Mirantis公司
===============

开发 ``k0s`` ( `k0sproject.io <https://k0sproject.io>`_) 的软件公司是 Mirantis ，最早是一家外包公司。但是，从 :ref:`openstack` 开始发布就进入OpenStack的开发即全面转型，并且不断融资成为OpenStack领域数一数二的公司。Mirantis不仅发行商业化OpenStack也是全球顶尖的OpenStack服务供应商。

随着容器化技术和Kubernetes的崛起，Mirantis开始转型成OpenStack和Kubernetes结合的云计算服务商。并且在2019年底，通过收购 :ref:`docker` 的Enterprise业务，一跃成为容器化和Kubernetes领域重要的玩家。现在Mirantis公司已经是业务从 OpenStack，到 Kubernetes、Docker，再到 DevOps、Data Center 等覆盖面非常广的跨国公司。

参考
========

- `k0s vs k3s – Battle of the Tiny Kubernetes distros <https://www.virtualizationhowto.com/2023/07/k0s-vs-k3s-battle-of-the-tiny-kubernetes-distros/>`_
- `k3s vs k0s | 青训营创作 <https://juejin.cn/post/7196924295309656120>`_
- `用于本地实验的小型 Kubernetes：k0s、MicroK8s、kind、k3s 和 Minikube <https://zhuanlan.zhihu.com/p/594206344>`_
- `k0s/k0smotron：重新想象多集群 Kubernetes <https://cloud.tencent.com/developer/article/2402336>`_
- `k0s 折腾笔记 <https://mritd.com/2021/07/29/test-the-k0s-cluster/>`_
- `「容器云」k0s 另外一个 Kubernetes 发行版 <https://cloud.tencent.com/developer/article/1769519>`_
- `收购 Docker 企业业务的 Mirantis 是什么来路？ <https://2d2d.io/s1/mirantis/>`_
- `65 亿元的容器软件市场：红帽 30 亿、Mirantis 9.4 亿、VMware 4.8 亿、Rancher 2.4 亿 <https://zhuanlan.zhihu.com/p/386610745>`_
