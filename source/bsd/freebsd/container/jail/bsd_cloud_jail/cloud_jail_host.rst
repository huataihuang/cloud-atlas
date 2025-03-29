.. _cloud_jail_host:

=====================
FreeBSD云计算Jail主机
=====================

主机激活Jail
===============

- 在系统启动时启动Jails:

.. literalinclude:: ../jail_host/enable_jail
   :caption: 配置在系统启动时启动Jails

Jail网络
==========

我采用 **虚拟网络（VNET）** : 每个jail有隔离的网络堆栈，独立IP地址、路由表和网络接口(就像独立的虚拟机)

- 由于 :ref:`freebsd_wifi_bcm43602` 已经部署了 ``winfibox0`` bridge，所以这部分跳过。如果是常规Host主机，假设主机物理网卡是 ``em0`` ，则执行:

.. literalinclude:: ../vnet_jail/create_bridge
   :caption: 创建 ``bridge``

.. literalinclude:: ../vnet_jail/bridge_addm
   :caption: 将策划构建的 ``bridge`` 附加到物理网卡

为了能够在操作系统重启之后自动启动网桥，需要在 ``/etc/rc.conf`` 配置:

.. literalinclude:: ../vnet_jail/rc.conf
   :caption: 在 ``/etc/rc.conf`` 中配置网桥

.. warning::

   这部分Host准备 VNET 网桥，因为我的环境已经具备 ``winfibox0`` 所以跳过。后续如果在服务器部署，则需要这部分。

ZFS存储
=============

Jail目录树
---------------

目前采用FreeBSD Handbook中使用的 ``/usr/local/jails`` 目录(但我后续部署将改成 ``/jails`` )

.. literalinclude:: ../jail_host/jails_dir_zfs
   :caption: 创建jails目录( :ref:`zfs` )

除了 ``/usr/local/jails`` 目录外，其他目录还有:

- ``media`` 将包含已下载用户空间的压缩文件
- ``templates`` 在使用 Thin Jails 时，该目录存储模板(共享核心系统)
- ``containers`` 将存储jail (也就是容器)

``data/docs`` 数据集
----------------------

- ``zroot/data/docs`` 存储日常工作数据文档，这个目录在Host主机上维护，通过 NullFS 输出给 ``dev`` Jail

.. literalinclude:: cloud_jail_host/zfs_docs
   :caption: 创建 ``docs`` 数据集

``data/pgdb`` 数据集
-----------------------

.. note::

   计划将 :ref:`pgsql_in_jail` 数据部分单独使用ZFS数据集存储，待补充

Jail配置文件
===============

我采用 ``/etc/jail.conf`` 结合 ``/etc/jail.conf.d/`` 目录下配置:

- ``/etc/jail.conf`` 提供所有Jail的公共部分
- ``/etc/jail.conf.d/`` 目录中为每个jail创建一个文件，其中内容是每个Jail的特定区别部分
- FreeBSD Jail运行时会自动合并两部分配置，形成一个完整的Jail配置

设置 ``/etc/jail.conf`` 公共部分:

