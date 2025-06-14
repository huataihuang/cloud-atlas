.. _vnet_thin_jail:

=========================
VNET + Thin Jail
=========================

在实践了不同的FreeBSD Jail技术之后，我在 `cloud-atlas.dev <https://cloud-atlas.dev>`_ 实践中，采用了FreeBSD VNET + Thin Jail 来构建基础环境:

- 使用 NullFS Thin Jail尽可能节约磁盘空间，同时提供FreeBSD核心的升级同时共享给多个Jail
- 选择 VNET 来构建完整的网络堆栈，以允许容器内部能够使用socks等网络底层技术

.. note::

   本文记录完整部署步骤，也就是从主机激活Jail功能开始到通过辅助脚本快速启动jail

   本文步骤也是 `云图「架构」: VNET + Thin Jail <http://docs.cloud-atlas.dev/zh-CN/architecture/container/jails/vnet-thin-jail#配置jail>`_

主机激活 jail
===============

- 执行以下命令配置在系统启动时启动 ``Jail`` :

.. literalinclude:: vnet_thin_jail/enable
   :caption: 激活jail

Jail目录树
=============

.. note::

   Jail文件的位置没有规定，在FreeBSD Handbook中采用的是 ``/usr/local/jails`` 目录。

   我为了方便管理和数据存储最大化，使用了 ``stripe 模式 ZFS`` 存储池 ``zdata`` 下的 ``/zdata/jails``

   注意，我使用了 ``jail_zfs`` 环境变量来指定ZFS位置，对应目录就是 ``/$jail_zfs``

- 创建jail目录结构

.. literalinclude:: vnet_thin_jail/dir
   :caption: jail目录结构

- 完成后检查 ``df -h`` 可以看到磁盘如下:

.. literalinclude:: vnet_thin_jail/df
   :caption: jail目录的zfs形式

.. note::

   - ``media`` 将包含已下载用户空间的压缩文件
   - ``templates`` 在使用 Thin Jails 时，该目录存储模板(共享核心系统)
   - ``containers`` 将存储jail (也就是容器)

``快照(snapshot)`` 型 vs. ``模板和NullFS`` 型
================================================

FreeBSD Thin Jail是基于 ZFS ``快照(snapshot)`` 或 ``模板和NullFS`` 来创建的 瘦 Jail:

- 使用区别:

  - ``快照(snapshot)`` 型: 快照只读的，不可更改的 - 这意味着 **没有办法简单通过更新共享的ZFS snapshot来实现Thin Jail操作系统更新**
  - ``模板和NullFS`` 型: 可以通过 **直接更新NullFS底座共享的ZFS dataset可以瞬间更新所有Thin Jail**

- 安装区别:

  - ZFS snapshot Thin Jail: 将FreeBSD Release base存放在 **只读** 的 ``14.2-RELEASE@base`` 快照上
  - NullFS Thin Jail: 将FreeBSD Release base存放在 **读写** 的 ``14.2-RELEASE-base`` 数据集上

通过结合Thin Jail 和 ``NullFS`` 技术可以创建节约文件系统存储开销(类似于 ZFS ``snapshot`` clone出来的卷完全不消耗空间)，并且能够将Host主机的目录共享给 **多个** Jail。

- 创建 **读写模式** 的 ``14.2-RELEASE-base`` (注意，大家约定俗成 ``@base`` 表示只读快照， ``-base`` 表示可读写数据集)

.. literalinclude:: vnet_thin_jail/templates_base
   :caption: 创建 **读写模式** 的 ``14.2-RELEASE-base``

- 下载用户空间:

.. literalinclude:: vnet_thin_jail/fetch
   :caption: 下载用户空间

- 将下载内容解压缩到模版目录: **内容解压缩到模板目录( 14.2-RELEASE-base 后续不需要创建快照，直接使用)**

.. literalinclude:: vnet_thin_jail/tar
   :caption: 解压缩

- 将时区和DNS配置复制到模板目录:

.. literalinclude:: vnet_thin_jail/cp
   :caption: 将时区和DNS配置复制到模板目录

- 更新模板补丁:

.. literalinclude:: vnet_thin_jail/update
   :caption: 更新模板补丁

- 创建一个特定数据集 ``skeleton`` (**骨骼**) ，这个 "骨骼" ``skeleton`` 命名非常形象，用意就是构建特殊的支持大量thin jial的框架底座

.. literalinclude:: vnet_thin_jail/zfs_create
   :caption: 创建skeleton

- 执行以下命令，将特定目录移入 ``skeleton`` 数据集，并构建 ``base`` 和 ``skeleton`` 必要目录的软连接关系

.. literalinclude:: vnet_thin_jail/skeleton_link
   :caption: 特定目录移入 ``skeleton`` 数据集

.. note::

   执行 ``mv /$jail_zfs/templates/$bsd_ver-RELEASE-base/var /$jail_zfs/templates/$bsd_ver-RELEASE-skeleton/var`` 有如下报错:

   .. literalinclude:: vnet_thin_jail/skeleton_link_error
      :caption: 报错

   这是因为  ``var/empty`` 目录没有权限删除: ``mv var/empty: Operation not permitted`` ，我采用以下workround绕过:

   .. literalinclude:: vnet_thin_jail/skeleton_link_fix
      :caption: 修复

- 执行以下命令创建软连接:

.. literalinclude:: vnet_thin_jail/link
   :caption: 创建软连接

- 在 ``skeleton`` 就绪之后，需要将数据复制到 jail 目录(如果是UFS文件系统)，对于ZFS则非常方便使用快照:

.. literalinclude:: vnet_thin_jail/snapshot
   :caption: 创建skeleton快照,然后再创建快照的clone(jail)

- 现在可以看到相关ZFS数据集如下:

.. literalinclude:: vnet_thin_jail/df_jail
   :caption: ZFS数据集显示jail存储
   :emphasize-lines: 10

- 创建一个 ``base`` template的目录，这个目录是 ``skeleton`` 挂载所使用的根目录

 .. literalinclude:: vnet_thin_jail/nullfs-base
    :caption: 创建 ``skeleton`` 挂载所使用的根目录

配置jail
============

.. note::

   - Jail的配置分为公共部分和特定部分，公共部分涵盖了所有jails共有的配置
   - 尽可能提炼出Jails的公共部分，这样就可以简化针对每个jail的特定部分，方便编写较稳维护

- 创建所有jail使用的公共配置部分 ``/etc/jail.conf`` (使用了 VNET 模式配置):

.. literalinclude:: vnet_thin_jail/jail.conf
   :caption: 所有jail使用的公共配置部分 ``/etc/jail.conf``

- ``/etc/jail.conf.d/dev.conf`` 独立配置部分:

.. literalinclude:: vnet_thin_jail/dev.conf
   :caption: ``/etc/jail.conf.d/dev.conf``

- 注意，这里配置引用了一个针对nullfs的fstab配置，所以还需要创建一个 ``/zdata/jails/dev-nullfs-base.fstab`` :

.. literalinclude:: vnet_thin_jail/fstab
   :caption: ``/zdata/jails/dev-nullfs-base.fstab``

- 最后启动 ``dev`` :

.. literalinclude:: vnet_thin_jail/start
   :caption: 启动 ``dev``   

通过 ``rexec dev`` 进入jail

- 设置Jail ``dev`` 在操作系统启动时启动，修改 ``/etc/rc.conf`` :

.. literalinclude:: vnet_thin_jail/rc.conf
   :caption: ``/etc/rc.conf``

脚本辅助配置jail
===================

- 写了一个简单的脚本帮助创建配置文件:

.. literalinclude:: vnet_thin_jail/jail_zfs.sh
   :caption: 创建jail的辅助脚本

通过执行 ``./jail_zfs.sh pg-1 111`` 就可以创建一个使用 ``192.168.7.111`` 为IP的名为 ``pg-1`` 的Jail
