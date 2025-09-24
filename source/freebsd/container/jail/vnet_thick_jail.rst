.. _vnet_thick_jail:

=====================================
VNET + Thick(厚) Jail(UFS)
=====================================

实践总是磕磕绊绊，我在 FreeBSD Alpha 2 上实践 :ref:`linux_jail` 发现在 :ref:`zfs` 上构建 :ref:`linux_jail` 或者关闭ZFS的压缩属性，都出现了无法解决的 **ls访问文件系统报错** ``Invalid argument``

考虑到UFS虽然能够实现 :ref:`thin_jail_ufs` ，但是如果使用NullFS应该还会和 :ref:`linux_jail` 的Linux分区文件系统挂载冲突，所以改为采用传统的 :ref:`thick_jail` ，在 :ref:`thick_jail` 基础上结合VNET的形成本文实践。

Thick Jail
==============

- 为方便调整，我设置了环境变量来方便后续操作

.. literalinclude:: vnet_thick_jail/env
   :caption: 设置 jail目录和release版本环境变量

- 下载用户空间(该步骤和 :ref:`thin_jail` / :ref:`vnet_thin_jail` 共用，所以下载文件位于 ZFS 存储卷中:

.. literalinclude:: vnet_thin_jail/fetch
   :caption: 下载用户空间

- 解压缩到jail目录:

.. literalinclude:: vnet_thick_jail/jail_name
   :caption: 设置一个 ``$jail_name`` 方便灵活配置( ``ludev`` )

.. literalinclude:: thick_jail/tar
   :caption: 解压缩到jail目录( ``ludev`` 命名)

- jail目录内容就绪以后，需要复制时区和DNS配置文件:

.. literalinclude:: thick_jail/conf
   :caption: 复制复制时区和DNS配置文件

- 更新最新补丁:

.. literalinclude:: thick_jail/update
   :caption: 更新jail

配置Thick Jail
==================

.. note::

   在 :ref:`vnet_thin_jail` 配置基础上完成

- 适合不同Jail的公共配置 ``/etc/jail.conf`` :

.. literalinclude:: vnet_thin_jail/jail.conf_common
   :caption: 混合多种jail的公共 ``/etc/jail.conf``

- UFS文件系统上构建的 ``ludev`` 独立配置 ``/etc/jail.conf.d/ludev.conf`` :

.. literalinclude:: vnet_thick_jail/ludev.conf
   :caption: UFS文件系统上构建的 ``ludev`` 独立配置 ``/etc/jail.conf.d/ludev.conf``
   :emphasize-lines: 6

启动jail
-----------------------

- 最后启动 ``ludev`` :

.. literalinclude:: vnet_thick_jail/start
   :caption: 启动 ``ludev``

通过 ``jexec ludev`` 进入jail

- 设置Jail ``ludev`` 在操作系统启动时启动，修改 ``/etc/rc.conf`` :

.. literalinclude:: vnet_thin_jail_snapshot/rc.conf
   :caption: ``/etc/rc.conf``
   :emphasize-lines: 4
