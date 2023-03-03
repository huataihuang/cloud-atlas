.. _intro_rook:

=============
Rook简介
=============

Rook是开源 **云原生存储协调器** ( ``cloud-native storage orchestrator`` )，提供了平台、框架以及支持将 :ref:`ceph` 存储原生集成到云原生环境。

.. note::

   Rook 原先还支持 NFS 和 Cassandra 管理，但是现在已经废弃:

   - `Rook NFS <https://github.com/rook/nfs>`_ 建议采用 :ref:`rook_cephnfs` (如果使用Rook) 或者 `NFS Ganesha server and external provisioner <https://github.com/kubernetes-sigs/nfs-ganesha-server-and-external-provisioner>`_ ( :ref:`k8s_nfs` )
   - `Rook Cassandra <https://github.com/rook/cassandra>`_ 建议采用 `k8ssandra/cass-operator <https://github.com/k8ssandra/cass-operator/>`_ 替代

Rook提供了自动化部署和管理Ceph，提供自我管理，自我伸缩，自我修复的存储服务。Rook operator通过Kubernetes资源来实现 :ref:`ceph` 的 部署、配置、提供、伸缩、升级以及监控。

Rook从2018年12月的Rook v0.9宣布进入稳定状态，并且已经提供了生产级别的存储平台。目前Rook已经是CNCF的毕业级别项目。



参考
=======

- `Rook Ceph Documentation: Getting Started - intro <https://rook.io/docs/rook/v1.11/Getting-Started/intro/>`_
