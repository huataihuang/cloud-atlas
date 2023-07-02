.. _deploy_centos7_gluster11:

=========================
CentOS 7 部署Gluster 11
=========================

.. note::

   CentOS 7.2作为GlusterFS服务器

准备工作
===========

- :ref:`build_glusterfs_11_for_centos_7`
- :ref:`gluster11_rpm_createrepo`

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

配置
=======

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


