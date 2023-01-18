.. _mobile_cloud_x86_kind:

=====================================
X86移动云Kind(本地docker模拟k8s集群)
=====================================

为了能够充分发挥古老的 :ref:`mbp15_late_2013` 笔记本 性能，只部署一个 :ref:`kind` 来实现开发环境 ``dev.cloud-atlas.io`` 。

安装kind
===========

- 由于我已经安装配置 :ref:`go_on_arch_linux` ，所以采用 ``go get`` / ``go install`` 方法安装 :ref:`kind` (需要翻墙):

.. literalinclude:: ../../../kubernetes/kind/kind_startup/go_install_kind
   :language: bash
   :caption: 使用go install命令安装kind

部署kind集群
===============

- 配置3个管控节点，5个工作节点的集群配置文件如下：

.. literalinclude:: ../../../kubernetes/kind/kind_multi_node/kind-config.yaml
   :language: yaml
   :caption: kind构建3个管控节点，5个工作节点集群配置

- 执行创建集群，集群命名为 ``dev`` :

.. literalinclude:: ../../../kubernetes/kind/kind_multi_node/kind_create_cluster
   :language: bash
   :caption: kind构建3个管控节点，5个工作节点集群配置
