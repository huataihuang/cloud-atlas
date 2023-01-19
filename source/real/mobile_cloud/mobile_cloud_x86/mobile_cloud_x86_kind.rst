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

- 修订 ``/etc/docker/dameon.json`` 激活 :ref:`buildkit` :

.. literalinclude:: ../../../kubernetes/kind/debug_mobile_cloud_x86_kind_create_fail/daemon.json
   :language: json
   :caption: 修改 /etc/docker/daemon.json 添加 buildkit 配置
   :emphasize-lines: 3-5

重启 ``docker`` 服务后，再执行下面的脚本获得最新的Dockerfile，并构建镜像:

.. literalinclude::  ../../../kubernetes/kind/debug_mobile_cloud_x86_kind_create_fail/build_node_image_by_lastest_dockerfile.sh
   :language: dockerfile
   :caption: 构建包含zfs工具的node镜像

.. note::

   需要翻越GFW: 容器内部proxy设置 :ref:`docker_client_proxy`

- 执行创建集群，集群命名为 ``dev`` :

.. literalinclude:: mobile_cloud_x86_kind/kind_create_cluster
   :language: bash
   :caption: kind构建3个管控节点，5个工作节点集群配置，指定自定义镜像(包括zfs工具)
