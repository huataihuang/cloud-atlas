.. _install_ceph:

==================
安装Ceph
==================

有多种方式安装Ceph:

建议方式
=============

``cephadm`` 工具提供了采用容器和systemd安装和管理Ceph集群，紧密结合了CLI和dashboard GUI :

- ``cephadm`` 只支持Octopus和更新版本
- ``cephadm`` 完全集成了新的orchestrator API和和管控面板(dashboard)功能来管理集群部署
- ``cephadm`` 需要容器支持(podman或 :ref:`docker` )以及Python 3

:ref:`rook` 可以在 :ref:`kubernetes` 集群中部署和管理 Ceph ，也提供了通过Kubernetes API提供存储资源管理和供应的能力。建议在Kubernetes中使用Rook来运行Ceph或连接已经存在的Ceph存储集群到Kubernetes

- Rook只支持 Nautilus 和更新版本Ceph
- Rook支持最新的orchestratorAPI，也完全支持CLI和dashboard功能

其他方式
============

``ceph-ansible`` 使用 :ref:`ansible` 部署和管理Ceph集群:

- ``ceph-ansible`` 被广泛使用
- ``ceph-ansible`` 没有集成最新的 orchestrator API (在Nautlius和Octopus版本引入)，也就是不支持最新的管理功能和dashboard集成

``ceph-deploy`` 已经不再活跃维护，没有在Nautilus以及更新版本测试过，也不支持RHEL8, CentOS8或更新版本

`DeepSea <https://github.com/SUSE/DeepSea>`_ 使用Salt安装Ceph

`jaas.ai/ceph-mon <https://jaas.ai/ceph-mon>`_ 使用Juju安装Ceph

`github.com/openstack/puppet-ceph <https://github.com/openstack/puppet-ceph>`_ 使用Puppet安装Ceph

我也实践了在 :ref:`priv_cloud_infra` 第一层虚拟化数据层采用 :ref:`install_ceph_manual`


参考
=======

- `INSTALLING CEPH <https://docs.ceph.com/en/pacific/install/>`_
