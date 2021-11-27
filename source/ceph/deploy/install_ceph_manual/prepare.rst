.. _install_ceph_manual_prepare:

=========================
手工安装Ceph - 准备工作
=========================

.. note::

   2021年10月我购买了 :ref:`hpe_dl360_gen9` 构建 :ref:`priv_cloud_infra` ，底层数据存储层采用Ceph实现。为了完整控制部署并了解Ceph组件安装，采用本文手工部署Ceph方式安装。

   部署采用3个 :ref:`ovmf` 虚拟机，通过 :ref:`iommu` 方式 pass-through :ref:`samsung_pm9a1` :ref:`nvme` 存储。也就是一共有3个 :ref:`kvm` 虚拟机来完成Ceph集群部署:

   - ``z-b-data-1`` (192.168.6.204)
   - ``z-b-data-2`` (192.168.6.205)
   - ``z-b-data-3`` (192.168.6.206)

   操作系统采用 :ref:`ubuntu_linux` 20.04.3 LTS

获取Ceph软件
=============

最简易获取软件的方法还是采用发行版的软件仓库，例如 ``apt`` (Debian/Ubuntu) 或 ``yum`` (RHEL/CentOS) ，如果使用非 ``deb`` 或 ``rpm`` 的软件包管理，则可以使用官方提供的tar包安装二进制可执行程序。

.. note::

   在多台服务器上同时操作，可以使用 :ref:`pssh`

安装Ceph软件
==============

.. note::

   为了能够完整了解Ceph集群部署过程，本文档没有使用 ``ceph-deploy`` 和 ``ceph-adm`` 工具，而是采用手工通过APT包管理工具进行部署。

- 安装Ceph软件包（在每个节点上执行）::

   sudo apt update && sudo apt install ceph ceph-mds

.. note::

   `INSTALL CEPH STORAGE CLUSTER <https://docs.ceph.com/en/pacific/install/install-storage-cluster/>`_ 提供了 APT 和 YUM 仓库安装方法

   对于通过对象存储模式使用Ceph，需要安装 ``Ceph Object Gateway`` ，我将另外撰写文章；对于虚拟化平台使用Ceph块设备则需要通过 ``librdb`` 驱动，我也会另外撰写实践文章。

Ceph集群的初始
=================

Ceph集群要求至少1个monitor，以及至少和对象存储的副本数量相同（或更多）的OSD运行在集群中。 monitor部署是整个集群设置的重要步骤，例如存储池的副本数量，每个OSD的placement groups数量，心跳间隔，是否需要认证等等。这些配置都有默认值，但是在部署生产集群需要仔细调整这些配置。

本案例采用3个节点：

.. figure:: ../../../_static/ceph/deploy/install_ceph_manual/simple_3nodes_cluster.png

   Figure 1: 三节点Ceph集群

.. note::

   我在部署初始采用1个monitor，准备后续再通过monitor方式扩容(缩容及替换)来演练生产环境的维护。

正式开始
============

依次完成以下安装过程:

- :ref:`install_ceph_mon`
- :ref:`install_ceph_mgr`
- :ref:`add_ceph_osds`

