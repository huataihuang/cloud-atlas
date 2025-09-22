.. _vnet_thin_jail_snapshot:

=============================
VNET + Thin Jail(Snapshot)
=============================

.. note::

   本文是 :ref:`thin_jail_using_zfs_snapshot` 的完整(补充)实践，以及结合 :ref:`vnet_jail` 完成的方案。

   同时，也是我实践 :ref:`linux_jail` 的基础(前置部分)

主机激活 jail
===============

- 执行以下命令配置在系统启动时启动 ``Jail`` :

.. literalinclude:: vnet_thin_jail/enable
   :caption: 激活jail

Jail目录树
=============

- 设置环境变量:

.. literalinclude:: vnet_thin_jail/env
   :caption: 设置 jail目录和release版本环境变量

- 创建jail目录结构

.. literalinclude:: vnet_thin_jail/dir
   :caption: jail目录结构

- 完成后检查 ``df -h`` 可以看到磁盘如下:

.. literalinclude:: vnet_thin_jail/df
   :caption: jail目录的zfs形式

快照(snapshot)
=================

.. note::

   :ref:`snapshot_vs_templates_nullfs_thin_jails` 说明两种不同的Thin Jail，本文是 OpenZFS Snapshots 类型的Thin Jail构建记录:

   - ZFS snapshot Thin Jail: 将FreeBSD Release base存放在 **只读** 的 ``14.3-RELEASE@base`` 快照上
   - NullFS Thin Jail: 将FreeBSD Release base存放在 **读写** 的 ``14.3-RELEASE-base`` 数据集上

   从这步开始可以看出两者不同

- 为OpenZFS Snapshot Thin Jail 准备模版dataset:

.. literalinclude:: vnet_thin_jail_snapshot/templates
   :caption: 创建 ``14.3-RELEASE`` 模版

- 下载用户空间:

.. literalinclude:: vnet_thin_jail/fetch
   :caption: 下载用户空间

- 将下载内容解压缩到模版目录: **内容解压缩到模板目录(后续要在14.3-RELEASE上创建快照，这就是和NullFS的区别)**

.. literalinclude:: vnet_thin_jail_snapshot/tar
   :caption: 解压缩

- 将时区和DNS配置复制到模板目录:

.. literalinclude:: vnet_thin_jail_snapshot/cp
   :caption: 将时区和DNS配置复制到模板目录

- 更新模板补丁:

.. literalinclude:: vnet_thin_jail_snapshot/update
   :caption: 更新模板补丁

.. note::

   从这里开始 Snapshot 类型Thin Jail 和 NullFS 类型Thin Jail开始出现步骤差异: 这里需要为base模版建立快照，然后clone(NullFS则创立快照，但只clone ``skeleton`` 部分保持读写)

- 为模版创建快照(完整快照):

.. literalinclude:: vnet_thin_jail_snapshot/base_snapshot
   :caption: 为RELEASE模版创建base快照

- 基于快照(snapshot)的Thin Jail 比 NullFS 类型简单很多，只要在模块快照基础上创建clone就可以生成一个新的Thin Jail:

.. literalinclude:: vnet_thin_jail_snapshot/jail_name
   :caption: 为了能够灵活创建jail，这里定义一个 ``jail_name`` 环境变量，方便后续调整jail命名

.. literalinclude:: vnet_thin_jail_snapshot/clone_ldev
   :caption: clone出一个名为 ``ldev`` 的Thin Jail(后续将进一步改造为 :ref:`linux_jail` )

- 现在可以看到相关ZFS数据集如下:

.. literalinclude:: vnet_thin_jail_snapshot/df_jail
   :caption: ZFS数据集显示jail存储
   :emphasize-lines: 9

配置Jail
==========

.. note::

   在 :ref:`vnet_thin_jail` 配置基础上完成

- 适合不同Jail的公共配置 ``/etc/jail.conf`` :

.. literalinclude:: vnet_thin_jail/jail.conf_common
   :caption: 混合多种jail的公共 ``/etc/jail.conf``

- 用于Snapshot类型的 ``ldev`` 独立配置 ``/etc/jail.conf.d/ldev.conf`` :

.. literalinclude:: vnet_thin_jail_snapshot/ldev.conf
   :caption: 用于Snapshot类型 ``/etc/jail.conf.d/ldev.conf``
   :emphasize-lines: 6

.. note::

   挂载路径和NullFS类型的Thin Jail不同

启动jail
-----------------------

- 最后启动 ``ldev`` :

.. literalinclude:: vnet_thin_jail_snapshot/start
   :caption: 启动 ``ldev``

通过 ``rexec jdev`` 进入jail

- 设置Jail ``ldev`` 在操作系统启动时启动，修改 ``/etc/rc.conf`` :

.. literalinclude:: vnet_thin_jail_snapshot/rc.conf
   :caption: ``/etc/rc.conf``
   :emphasize-lines: 4
