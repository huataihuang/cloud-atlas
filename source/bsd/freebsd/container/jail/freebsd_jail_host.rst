.. _freebsd_jail_host:

==========================
FreeBSD Jail Host主机配置
==========================

.. note::

   在 jail 中运行的 FreeBSD 版本不能比主机中运行的版本更新

主机激活Jail
===============

- 执行以下命令配置在系统启动时启动Jails:

.. literalinclude:: freebsd_jail_host/enable_jail
   :caption: 配置在系统启动时启动Jails

Jail网络
==============

FreeBSD jails的网络有以下不同方式:

- 主机网络模式（IP 共享）
- 虚拟网络（VNET）: 每个jail有隔离的网络堆栈，独立IP地址、路由表和网络接口(就像独立的虚拟机)
- netgraph 系统: netgraph是一个多功能内核框架，用于创建自定义网络配置，可以用于定义网络流量在 jails 和主机系统之间以及不同 jails 之间的流动方式

.. note::

   我觉得 VNET jail + Thin jail + Linux jail ，可以构建一个多IP的隔离容器来模拟多台主机，这样就可以部署类似 :ref:`kind` 这样的Kubernetes模拟集群，一个在FreeBSD上运行的模拟Kubernetes集群。

   以后试试...

Jail目录树
===============

Jail文件的位置没有规定，可以是 ``/jail`` , ``/usr/jail`` 或 ``/usr/local/jail`` ，在FreeBSD Handbook中采用的是 ``/usr/local/jails`` 目录:

.. literalinclude:: freebsd_jail_host/jails_dir_zfs
   :caption: 创建jails目录( :ref:`zfs` )

对jail也可以使用传统的UFS:

.. literalinclude:: freebsd_jail_host/jails_dir_ufs
   :caption: 创建jails目录(传统文件系统 UFS )

上面除了 ``/usr/local/jails`` 目录外，其他目录还有:

- ``media`` 将包含已下载用户空间的压缩文件
- ``templates`` 在使用 Thin Jails 时，该目录存储模板(共享核心系统)
- ``containers`` 将存储jail (也就是容器)

Jail配置文件
==============

有两种方法配置jails:

- 方法一: 在 ``/etc/jail.conf`` 中为每个jail添加一个条目
- 方法二: 在 ``/etc/jail.conf.d/`` 目录中为每个jail创建一个文件 (我采用这个方法，适合管理大量的jails)

.. literalinclude:: freebsd_jail_host/jail.conf
   :caption: 在 ``/etc/jail.conf`` 中添加一行配置来包含所有在 ``/etc/jail.conf.d/`` 目录下以 ``.conf`` 结尾的配置

典型Jail配置
--------------

.. literalinclude:: freebsd_jail_host/typical_jail.conf
   :caption: 典型的jail配置

开始创建
===========

Host 准备工作已经完成，现在开始创建:

- :ref:`freebsd_thick_jail`
- :ref:`freebsd_thin_jail`
