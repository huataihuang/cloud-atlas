.. _mobile_cloud_ceph_prepare:

===============================
移动云计算安装Ceph - 准备工作
===============================


2021年10月我购买了 :ref:`hpe_dl360_gen9` 构建 :ref:`priv_cloud_infra` ，底层数据存储层采用Ceph实现。为了完整控制部署并了解Ceph组件安装，采用本文手工部署Ceph方式安装。

部署采用3个 :ref:`ovmf` 虚拟机，采用 :ref:`mobile_cloud_libvirt_lvm_pool` 。也就是一共有3个 :ref:`kvm` 虚拟机来完成Ceph集群部署:

   - ``a-b-data-1`` (192.168.8.204)
   - ``a-b-data-2`` (192.168.8.205)
   - ``a-b-data-3`` (192.168.8.206)

操作系统采用 :ref:`fedora` 37 Server ARM

虚拟机环境准备
================

- 采用 :ref:`mobile_cloud_kvm` 构建虚拟机
- 虚拟机上部署 :ref:`ssh_key` 确保各个主机间无需密码SSH和SCP，方便部署

获取Ceph软件
=============

Ceph对 :ref:`redhat_linux` 系的支持极好(毕竟开发公司是红帽子公司)采用发行版的软件仓库，在 :ref:`fedora` 上可以直接采用官方仓库安装。

安装Ceph软件
==============

.. note::

   本文档和 :ref:`install_ceph_manual` 相同，采用手工通过rpm包管理工具进行部署。

:ref:`fedora` 内置了Ceph软件包仓库配置，无需配置可以直接安装。对于 debian 或 redhat 系，可以参考 `Ceph: GET PACKAGES <https://docs.ceph.com/en/pacific/install/get-packages/>`_ 获得软件仓库配置

- 安装Ceph软件包（在每个节点上执行）::

   sudo dnf update && sudo dnf install ceph ceph-mds

.. note::

   `INSTALL CEPH STORAGE CLUSTER <https://docs.ceph.com/en/pacific/install/install-storage-cluster/>`_ 提供了 APT 和 YUM 仓库安装方法

   对于通过对象存储模式使用Ceph，需要安装 ``Ceph Object Gateway`` ，我将另外撰写文章；对于虚拟化平台使用Ceph块设备则需要通过 ``librdb`` 驱动，我也会另外撰写实践文章。

Ceph集群的初始
=================

Ceph集群要求至少1个monitor，以及至少和对象存储的副本数量相同（或更多）的OSD运行在集群中。 monitor部署是整个集群设置的重要步骤，例如存储池的副本数量，每个OSD的placement groups数量，心跳间隔，是否需要认证等等。这些配置都有默认值，但是在部署生产集群需要仔细调整这些配置。

本案例采用3个节点：

.. figure:: ../../../_static/ceph/deploy/install_ceph_manual/simple_3nodes_cluster.png

   Figure 1: 三节点Ceph集群

正式开始
============

依次完成以下安装过程:

- :ref:`mobile_cloud_ceph_mon`
- :ref:`mobile_cloud_ceph_mgr`
- :ref:`mobile_cloud_ceph_add_ceph_osds_lvm`

