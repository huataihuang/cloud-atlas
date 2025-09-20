.. _linux_jail:

======================
FreeBSD Linux Jail
======================

.. note::

   我之前曾经实践过 :ref:`linux_jail_archive` ，但是当时经验不足折腾了很久记录也比较杂乱。最近我准备构建一个在FreeBSD系统编译 :ref:`lfs` ，也就是通过Linux Jail模拟出一个Linux环境，来访问和FreeBSD共存的Linux分区，通过这个模拟linux jail来编译LFS。

   本文是重新实践的笔记，我将采用ZFS存储上构建 :ref:`vnet_thin_jail` 基础上部署linux jail

FreeBSD Linux Jail是在FreeBSD Jail中激活支持Linux二进制程序的一种实现，通过一个允许Linux系统调用和库的兼容层来实现转换和执行在FreeBSD内核上。这种特殊的Jail可以无需独立的linux虚拟机就可以运行Linux软件。

VNET + Thin Jail
==================

主机激活 jail
-----------------

- 执行以下命令配置在系统启动时启动 ``Jail`` :

.. literalinclude:: vnet_thin_jail/enable
   :caption: 激活jail

Jail目录树
--------------

- 使用了 ``jail_zfs`` 环境变量来指定ZFS位置，为Jail创建目录树:

.. literalinclude:: vnet_thin_jail/env
   :caption: 设置 jail目录和release版本环境变量

- 创建jail目录结构

.. literalinclude:: vnet_thin_jail/dir
   :caption: jail目录结构

- 完成后检查 ``df -h`` 可以看到磁盘如下:

.. literalinclude:: vnet_thin_jail/df
   :caption: jail目录的zfs形式

模版和NullFS型Thin Jails
----------------------------------

.. note::

   :ref:`snapshot_vs_templates_nullfs_thin_jails`

通过结合Thin Jail 和 ``NullFS`` 技术可以创建节约文件系统存储开销(类似于 ZFS ``snapshot`` clone出来的卷完全不消耗空间)，并且能够将Host主机的目录共享给 多个 Jail。

- 创建 **读写模式** 的 ``14.3-RELEASE-base`` (注意，大家约定俗成 ``@base`` 表示只读快照， ``-base`` 表示可读写数据集)

.. literalinclude:: vnet_thin_jail/templates_base
   :caption: 创建 **读写模式** 的 ``14.3-RELEASE-base``

- 下载用户空间:

.. literalinclude:: vnet_thin_jail/fetch
   :caption: 下载用户空间

待续...

参考
======

- `FreeBSD Handbook: Chapter 17. Jails and Containers <https://docs.freebsd.org/en/books/handbook/jails/>`_
- `(Solved)How to have network access inside a Linux jail? <https://forums.freebsd.org/threads/how-to-have-network-access-inside-a-linux-jail.76460/>`_ 这个讨论非常详细，是解决Linux Jail普通用户网络问题的线索
- `(Solved)No internet access from inside jail! <https://forums.freebsd.org/threads/no-internet-access-from-inside-jail.78576/>`_
- `ping as non-root fails due to missing capabilities #143 <https://github.com/grml/grml-live/issues/143>`_ 
- `Setting up a (Debian) Linux jail on FreeBSD <https://forums.freebsd.org/threads/setting-up-a-debian-linux-jail-on-freebsd.68434/>`_ 一篇非常详细的Linux Jail实践

