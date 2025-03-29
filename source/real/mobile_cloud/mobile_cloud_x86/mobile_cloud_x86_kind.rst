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

采用 :ref:`kind_multi_node` 方法部署kind集群

- 配置3个管控节点，5个工作节点的集群配置文件如下：

.. literalinclude:: ../../../kubernetes/kind/kind_multi_node/kind-config.yaml
   :language: yaml
   :caption: kind构建3个管控节点，5个工作节点集群配置

.. note::

   这里遇到启动管控节点失败超时问题，见 :ref:`debug_mobile_cloud_x86_kind_create_fail` ，原因是 ``kind`` 镜像内部需要具有 ``zfs`` 工具才能在 :ref:`mobile_cloud_x86_zfs` 构建的 :ref:`docker` 上运行

由于ZFS作为物理主机 :ref:`docker_zfs_driver` ，需要采用自定义镜像(当前 ``kind`` 的修复只在官方github仓库，尚未release，后续新版本release可无需本步骤):

.. note::

   :ref:`debug_mobile_cloud_x86_kind_create_fail` 暂时没有解决ZFS文件系统上运行kind，官方git仓库中已经修复，但是尚未release。自己build太折腾，暂时放弃，等下一个版本 ``v0.8`` 应该就能解决

待续...
