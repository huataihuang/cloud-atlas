.. _rook:

=================================
Rook - 云原生存储调度器
=================================

Rook是一个开源的云原生存储调度器，提供平台，框架以及支持不同存储解决方案集成到云原生环境。用于在Kubernetes集群中管理和部署 :ref:`ceph` 。

和直接采用 ``ceph-rbd`` 以及 ``cephfs`` 不同， ``Rook`` 不是基于现有已经部署好的 :ref:`ceph` 集群，而是在 Kubernetes 的内部完整运行一套ceph集群，从0开始的的存储集群部署。

.. toctree::
   :maxdepth: 1

   

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
