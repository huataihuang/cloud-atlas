.. _deploy_centos7_gluster11_mdadm_raid10:

=============================================
在软RAID10上 CentOS 7 部署Gluster 11
=============================================

.. note::

   根据 :ref:`deploy_centos7_gluster11` 迭代改进部署方案

之前在项目方案上，改进了 :ref:`deploy_centos7_gluster11` (物理服务器上的12个 ``brick`` 用于同一个volume,但限制了集群的扩容和缩容)，基于 :ref:`think_best_practices_for_gluster` ，优化为底层采用 :ref:`linux_software_raid` 来统一存储磁盘，实现一个超大规模的磁盘，然后借助 :ref:`linux_lvm` 来实现灵活的卷划分和管理(实际项目部署还是简化去掉了LVM)。实施方案 :ref:`deploy_centos7_gluster11_lvm_mdadm_raid10` 我其实没有写完(没时间)。

不过，最近发现 :ref:`raid_check` 带来一个困扰，所以我想在虚拟机环境中完全模拟线上环境构建一个GlusterFS集群(唯一的差别是，每块磁盘我只模拟2GB大小)，以便完成一系列的测试验证以及监控部署方案。所以有本文记录

准备工作
===========

- :ref:`build_glusterfs_11_for_centos_7`
- :ref:`gluster11_rpm_createrepo`

磁盘存储池构建
================

- :ref:`mdadm_raid10` 完全按照线上环境模拟(每个虚拟机配置12块2GB的虚拟磁盘)

安装和启动服务
===============

- 安装方法同 :ref:`deploy_centos7_gluster6` :

.. literalinclude:: deploy_centos7_gluster11/yum_install_glusterfs-server
   :caption: 在CentOS上安装GlusterFS

输出显示将安装如下软件包:

.. literalinclude:: deploy_centos7_gluster11/yum_install_glusterfs-server_output
   :caption: 在CentOS上安装GlusterFS输出信息

- 启动GlusterFS管理服务:

.. literalinclude:: deploy_centos7_gluster11/systemctl_enable_glusterd
   :caption: 启动和激活GlusterFS管理服务

- 检查 ``glusterd`` 服务状态:

.. literalinclude:: deploy_centos7_gluster11/systemctl_status_glusterd
   :caption: 检查GlusterFS管理服务

输出显示服务运行正常:

.. literalinclude:: deploy_centos7_gluster11/systemctl_status_glusterd_output
   :caption: 检查GlusterFS管理服务显示运行正常

- 在所有需要的CentOS 7.2服务器节点都安装好上述 ``gluster-server`` 软件包( 使用 :ref:`pssh` ):

.. literalinclude:: deploy_centos7_gluster11/pssh_install_glusterfs-server
   :caption: 使用 :ref:`pssh` 批量安装 glusterfs-server

如果简单ssh执行通过如下方式完成:

.. literalinclude:: deploy_centos7_gluster11/ssh_install_glusterfs-server
   :caption: 简单使用 :ref:`ssh` 顺序循环安装 glusterfs-server

配置服务
==========

-  CentOS 7 默认启用了防火墙(视具体部署)，确保服务器打开正确通讯端口:

.. literalinclude:: deploy_centos7_gluster11/centos7_open_ports_glusterfs
   :caption: 为GlusterFS打开CentOS防火墙端口

.. note::

   - 在采用分布式卷的配置时，需要确保 ``brick`` 数量是 ``replica`` 数量的整数倍。举例，配置 ``replica 3`` ，则对应 ``bricks`` 必须是 ``3`` / ``6`` / ``9`` 依次类推
   - 部署案例中，采用了 ``6`` 台服务器，每个服务器 ``12`` 块NVME磁盘: ``12*6`` (3的整数倍)

- 配置gluster配对 **只需要在一台服务器上执行一次** :

.. literalinclude:: deploy_centos7_gluster11/gluster_peer_probe
   :language: bash
   :caption: 在 **一台** 服务器上 **执行一次** ``gluster peer probe``

- 完成后检查 ``gluster peer`` 状态:

.. literalinclude:: deploy_centos7_gluster11/gluster_peer_status
   :caption: 在 **一台** 服务器上执行 ``gluster peer status`` 检查peer是否创建并连接成功

.. literalinclude:: deploy_centos7_gluster11/gluster_peer_status_output
   :caption: ``gluster peer status`` 输出显示 ``peer`` 是 ``Connected`` 状态则表明构建成功
   :emphasize-lines: 5

创建GlusterFS卷
==================

- 创建一个简单的脚本 ``create_gluster`` ，方便构建 ``replica 3`` 的分布式卷:

.. literalinclude:: deploy_centos7_gluster11/create_gluster
   :language: bash
   :caption: ``create_gluster`` 脚本，传递卷名作为参数就可以创建 ``replica 3`` 的分布式卷

.. note::

   当 ``brick`` 数量是 ``replica`` 的整数倍(2倍或更多倍)时， :ref:`distributed_replicated_glusterfs_volume` 自动创建，能够同时获得高可用和高性能。但是对 ``brick`` 的排列有要求: 先 ``replica`` 后 ``distribute`` 。

   所以为了能将数据分布到不同服务器上，我这里采用了特定的排列顺序: ``A:0,B:0,C:0,A:1,B:1,C:1,A:2,B2,C2...`` 以便让 ``replicas 3`` 能够精确分布到不同服务器上。

   这种部署方式有利有弊: :ref:`best_practices_for_gluster` 我会详细探讨

- 将脚本加上执行权限::

   chmod 755 create_gluster

- 创建卷，举例是 ``backup`` :

.. literalinclude:: deploy_centos7_gluster11/create_gluster_backup_vol
   :language: bash
   :caption: ``create_gluster`` 脚本创建 ``backup`` 三副本分布式卷

- 如果创建卷错误，通过以下方式删除:

.. literalinclude:: deploy_centos7_gluster11/delete_gluster_backup_vol
   :language: bash
   :caption: 删除 ``backup`` 卷

.. note::

   这里在执行 ``gluster volume`` 的 ``stop`` 和 ``delete`` 命令时，都添加了参数 ``--mode=script`` 是为了避免交互，方便脚本命令执行。日常运维则可以不用这个参数，方便交互确认。

- 完成后检查卷状态:

.. literalinclude:: deploy_centos7_gluster11/gluster_volume_status
   :language: bash
   :caption: 检查 ``backup`` 卷状态

挂载gluster卷
====================

- 在客户端服务器只需要安装 ``gluster-fuse`` 软件包:

.. literalinclude:: deploy_centos7_gluster11/install_gluster-fuse
   :caption: 安装GlusterFS客户端 ``gluster-fuse``

- 修改 ``/etc/fstab`` 添加如下内容:

.. literalinclude:: deploy_centos7_gluster11/gluster_fuse_fstab
   :caption: GlusterFS客户端的 ``/etc/fstab``

- 挂载存储卷:

.. literalinclude:: deploy_centos7_gluster11/mount_gluster
   :caption: 挂载GlusterFS卷
