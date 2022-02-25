.. _pi_cluster:

=================================
Raspberry Pi Cluster
=================================

方案概述
==========

- 通过合理的硬件组合，形成树莓派多节点硬件集群
  - 模仿刀片服务器
- 树莓派管控节点提供Diskless集群自动部署
  - 无需人工干预自举部署基础操作系统，形成集群运行环境
  - 集成基础环境监控
- 在集群基础上构建 :ref:`kubernetes`
  - 实现应用容器按需交付
- 在Kubernetes基础上构建 :ref:`openshift`
  - 实现应用服务自动交付

本章节专注基础服务器集群的自动部署

.. toctree::
   :maxdepth: 1

   pi_stack.rst
   diskless_pi_cluster.rst
   autodeploy_pi_os.rst

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
