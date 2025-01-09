.. _cloud_jail_host:

=====================
FreeBSD云计算Jail主机
=====================

- 在系统启动时启动Jails:

.. literalinclude:: ../jail_host/enable_jail
   :caption: 配置在系统启动时启动Jails

ZFS存储
=============

``data/docs`` 数据集
----------------------

- ``zroot/data/docs`` 存储日常工作数据文档

.. literalinclude:: cloud_jail_host/zfs_docs
   :caption: 创建 ``docs`` 数据集
