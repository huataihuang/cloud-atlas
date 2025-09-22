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

- 将下载内容解压缩到模版目录: **内容解压缩到模板目录( 14.3-RELEASE-base 后续不需要创建快照，直接使用)**

.. literalinclude:: vnet_thin_jail/tar
   :caption: 解压缩

- 将时区和DNS配置复制到模板目录:

.. literalinclude:: vnet_thin_jail/cp
   :caption: 将时区和DNS配置复制到模板目录

- 更新模板补丁:

.. literalinclude:: vnet_thin_jail/update
   :caption: 更新模板补丁

.. note::

   我的最近一次实践是在 ``15.0-ALPHA2`` 上运行 ``14.3-RELEASE`` Jail，由于 ``freebsd-update`` 不支持ALPHA，则更新会报错(同 :ref:`freebsd_15_alpha_update_upgrade` ):

   .. literalinclude:: ../../admin/freebsd_15_alpha_update_upgrade/fetch_error
      :caption: 在FreeBSD 15 Alpha 2 上执行 ``freebsd-update`` 报错
      :emphasize-lines: 9,13

- 创建一个特定数据集 ``skeleton`` (**骨骼**) ，这个 "骨骼" ``skeleton`` 命名非常形象，用意就是构建特殊的支持大量thin jail的框架底座

.. literalinclude:: vnet_thin_jail/zfs_create
   :caption: 创建特定数据集 ``skeleton`` (骨骼)

- 执行以下命令，将特定目录移入 ``skeleton`` 数据集，并构建 ``base`` 和 ``skeleton`` 必要目录的软连接关系

.. literalinclude:: vnet_thin_jail/skeleton_link
   :caption: 特定目录移入 ``skeleton`` 数据集

.. note::

   部分移动命令和手册不同，原因见 :ref:`vnet_thin_jail`

- 执行以下命令创建软连接:

.. literalinclude:: vnet_thin_jail/link
   :caption: 创建软连接

- **在host上执行** 修复 ``/etc/ssl/certs`` 目录下证书文件软链接

.. literalinclude:: vnet_thin_jail/fix_link.sh
   :caption: 修复软链接

.. note::

   需要修复 ``/etc/ssl/certs`` 目录下证书文件软链接，原因见 :ref:`vnet_thin_jail`

- 在 ``skeleton`` 就绪之后，需要将数据复制到 jail 目录(如果是UFS文件系统请参考 :ref:`thin_jail_ufs` )，对于ZFS则非常方便使用快照:

.. literalinclude:: linux_jail/jail_name
   :caption: 为了能够灵活创建jail，这里定义一个 ``jail_name`` 环境变量，方便后续调整jail命名

.. literalinclude:: vnet_thin_jail/snapshot
   :caption: 创建skeleton快照,然后再创建快照的clone(jail)

- 现在可以看到相关ZFS数据集如下:

.. literalinclude:: linux_jail/df_jail
   :caption: ZFS数据集显示jail存储
   :emphasize-lines: 10

- 创建一个 ``base`` template的目录，这个目录是 ``skeleton`` 挂载所使用的根目录

 .. literalinclude:: vnet_thin_jail/nullfs-base
    :caption: 创建 ``skeleton`` 挂载所使用的根目录

配置VNET+Thin Jails
----------------------------

.. note::

   首先配置 :ref:`vnet_thin_jail` ，运行起来以后再调整为Linux Jail

   - Jail的配置分为公共部分和特定部分，公共部分涵盖了所有jails共有的配置
   - 尽可能提炼出Jails的公共部分，这样就可以简化针对每个jail的特定部分，方便编写校验维护

- 创建所有jail使用的公共配置部分 ``/etc/jail.conf`` (使用了 VNET 模式配置):

.. literalinclude:: vnet_thin_jail/jail.conf
   :caption: 所有jail使用的公共配置部分 ``/etc/jail.conf``

- ``/etc/jail.conf.d/$jail_name.conf`` 独立配置部分:

.. literalinclude:: linux_jail/ldev.conf
   :caption: ``/etc/jail.conf.d/ldev.conf`` (jail名为 ``ldev`` )

- 注意，这里配置引用了一个针对nullfs的fstab配置( ``ldev-nullfs-base.ftab`` )，所以还需要创建一个 ``/zdata/jails/$jail_name-nullfs-base.fstab`` :

.. literalinclude:: linux_jail/fstab
   :caption: ``/zdata/jails/$jail_name-nullfs-base.fstab``

- 最后启动 ``$jail_name`` ( ``ldev`` ) :

.. literalinclude:: vnet_thin_jail/start
   :caption: 启动 ``$jail_name`` ( ``ldev`` )

Linux Jail
==============

Linux Jail是在常规Jail上启用 Linux ABI实现

- 首先激活启动时Linux ABI支持:

.. literalinclude:: linux_jail/enable
   :caption: 激活启动时Linux ABI支持

- 一旦激活，就可以执行以下命令无需重启系统:

.. literalinclude:: linux_jail/start
   :caption: 启动Linux ABI支持

- 现在进入 ``ldev`` 容器:

.. literalinclude:: linux_jail/jexec
   :caption: 进入 ``ldev`` 容器 

- 在jail内部执行以下命令安装 ``sysutils/debootstrap`` 以便安装 :ref:`ubuntu_linux` 环境:

.. literalinclude:: linux_jail/debootstrap
   :caption: 安装 ``debootstrap`` 部署Ubuntu

.. note::

   所有 ``debootstrap`` 使用的脚本都存储在 ``/usr/local/share/debootstrap/scripts/`` 目录，目前只支持 Ubuntu 22.04 (jammy)。如果要安装更高版本，请参考 :ref:`linux_jail_ubuntu-base`

- 暂时停止 ``ldev`` jail:

.. literalinclude:: linux_jail/stop
   :caption: 停止 jail

- 修订 ``/zdata/jails/$jail_name-nullfs-base.fstab`` ，将原先挂载FreeBSD base系统的目录修改为挂载Linux目录



- 修订 ``/etc/jail.conf.d/ldev.conf`` 添加挂载配置:

.. literalinclude:: linux_jail/ldev_mount.conf
   :caption: 为 ``/etc/jail.conf.d/ldev.conf`` 添加挂载配置
   :emphasize-lines: 6-13

- 然后启动 ``ldev`` :

.. literalinclude:: linux_jail/start
   :caption: 启动Linux ABI支持

异常排查
==========

- 启动 ``ldev`` 时候提示 为避免资源死锁，拒绝挂载 

参考
======

- `FreeBSD Handbook: Chapter 17. Jails and Containers <https://docs.freebsd.org/en/books/handbook/jails/>`_
- `(Solved)How to have network access inside a Linux jail? <https://forums.freebsd.org/threads/how-to-have-network-access-inside-a-linux-jail.76460/>`_ 这个讨论非常详细，是解决Linux Jail普通用户网络问题的线索
- `(Solved)No internet access from inside jail! <https://forums.freebsd.org/threads/no-internet-access-from-inside-jail.78576/>`_
- `ping as non-root fails due to missing capabilities #143 <https://github.com/grml/grml-live/issues/143>`_ 
- `Setting up a (Debian) Linux jail on FreeBSD <https://forums.freebsd.org/threads/setting-up-a-debian-linux-jail-on-freebsd.68434/>`_ 一篇非常详细的Linux Jail实践

