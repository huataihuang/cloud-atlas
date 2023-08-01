.. _add_centos7_gluster11_server:

=========================================
CentOS 7上部署的Gluster 11 集群添加服务器
=========================================

在完成 :ref:`deploy_centos7_gluster11` 后，我需要为集群增加服务器节点，扩容服务器。

准备工作
===========

- :ref:`build_glusterfs_11_for_centos_7`
- :ref:`gluster11_rpm_createrepo` **添加仓库配置**

安装和启动服务
===============

- 安装方法同 :ref:`deploy_centos7_gluster6` :

.. literalinclude:: deploy_centos7_gluster11/yum_install_glusterfs-server
   :caption: 在CentOS上安装GlusterFS

- 启动GlusterFS管理服务:

.. literalinclude:: deploy_centos7_gluster11/systemctl_enable_glusterd
   :caption: 启动和激活GlusterFS管理服务

- 检查 ``glusterd`` 服务状态:

.. literalinclude:: deploy_centos7_gluster11/systemctl_status_glusterd
   :caption: 检查GlusterFS管理服务

添加GlusterFS新节点
======================

- 配置gluster配对 **只需要在一台服务器上执行一次** (可以在第一台服务器上) ，这里添加的服务器是我们集群的第7台服务器，不过由于只添加一台不需要区分，所以所以我命名为 ``server`` :

.. literalinclude:: add_centos7_gluster11_server/gluster_peer_probe
   :language: bash
   :caption: 在 **一台** 服务器上 **执行一次** ``gluster peer probe`` 添加这台新服务器

- 完成后检查 ``gluster peer`` 状态:

.. literalinclude:: deploy_centos7_gluster11/gluster_peer_status
   :caption: 在 **一台** 服务器上执行 ``gluster peer status`` 检查新添加节点是否正确连接到集群

.. literalinclude:: add_centos7_gluster11_server/gluster_peer_status_output
   :caption: ``gluster peer status`` 输出显示 ``peer`` 是 ``Connected`` 状态则表明构建成功
   :emphasize-lines: 23-25

- 依然是采用 :ref:`deploy_centos7_gluster11` 的卷，所以扩展(也就是 ``add_brick`` )采用如下简单脚本:

.. literalinclude:: add_centos7_gluster11_server/add_gluster
   :language: bash
   :caption: ``create_gluster`` 脚本，传递卷名作为参数就可以 **扩展** ( ``add_brick`` ) 现有的``replica 3`` 分布式卷

这里有一个报错提示:

.. literalinclude:: add_centos7_gluster11_server/add_gluster_error
   :language: bash
   :caption: ``add_brick`` 提示为一个replica卷添加的多个brick位于相同服务器上，不是优化设置

我验证了一下，确实可以在命令最后加上 ``force`` 关键字完成 ``add_brick`` ，但是给我带来如下困扰

- 新添加的 ``brick`` 全部排在 ``bricks`` 列表的最后:

.. literalinclude:: ../../startup/gluster_architecture/gluster_volume_info
   :caption: 执行 ``gluster volume info`` 可以检查卷信息

可以看到最后添加的 ``192.168.1.7`` 所有的bricks:

.. literalinclude:: add_centos7_gluster11_server/gluster_volume_info_output
   :caption: 执行 ``gluster volume info`` 看到新增加的服务器上所有bricks都是列在最后
   :emphasize-lines: 26-39

这里扩容的新节点有一个严重的问题，所有 ``bricks`` 都位于一台服务器上，会使得一部分hash到 ``brick73`` 到 ``brick84`` 的数据全部落在一台服务器上: :ref:`gluster_underlay_filesystem` 采用裸盘 :ref:`xfs` 带来的限制就是服务器节点不可增加或缩减

.. note::

   我将在 :ref:`best_practices_for_gluster` 详细探讨我的实践方案以及总结改进

参考
======

- `rackspace docs: Add and Remove GlusterFS Servers <https://docs.rackspace.com/docs/add-and-remove-glusterfs-servers>`_
