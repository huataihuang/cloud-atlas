.. _priv_cloud_infra_2025:

===============================
私有云架构2025
===============================

2025年一月，回顾最初构建「Cloud Atlas」，我购买的二手 :ref:`hpe_dl360_gen9` 已经使用了三年多，当初磕磕绊绊摸索实践的 :ref:`priv_cloud_infra` ，有些已经实现、有些则一直在脑海中未曾落地。

作为项目重启，我准备在2025年重新出发，来完成 `cloud-atlas.io <https://cloud-atlas.io/>`_ 从0开始的实践:

- 二手 :ref:`hpe_dl360_gen9` 将继续发光发热，作为主力计算密集设备(这是我投资最多的二手企业级设备):

  - 源码编译构建 :ref:`lfs` 和 :ref:`blfs` 作为 :ref:`kvm` 虚拟化底座，用最小化的内核和OS来构建坚如磐石的Host主机

    - 所有软件包都手工编译和维护，不断打磨以实现最优化

- 虚拟化部署: 通过 :ref:`kvm_nested_virtual` 构建模拟集群

  - :ref:`openstack`
  - :ref:`kubernetes`
  - :ref:`openshift`

- :ref:`machine_learning`

  - :ref:`tesla_p10` 和 :ref:`tesla_t10` 廉颇老矣尚能饭否: 学习部署和维护基于 :ref:`kubernetes` 容器化的大规模集群
  - 从0开始系统学习

虚拟化服务器分布
=================

.. csv-table:: zcloud服务器部署多层虚拟化虚拟机分配
   :file: priv_cloud_infra_2025/hosts.csv
   :widths: 10, 10, 10, 10, 10, 10, 10, 30
   :header-rows: 1
