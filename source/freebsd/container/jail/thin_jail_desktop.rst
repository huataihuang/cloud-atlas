.. _thin_jail_desktop:

=========================
桌面环境 Thin Jail
=========================

我在 `cloud-atlas.dev <https://cloud-atlas.dev>`_ 实践中，服务器端采用了:ref:`vnet_thin_jail` 来构建环境。不过，当我在 :ref:`freebsd_on_thinkpad_x220` 并构建 :ref:`freebsd_desktop` 时，没有使用 :ref:`vnet_jail` ，而仅仅使用 :ref:`thin_jail` :

- 桌面电脑没有服务器端分配的多个(固定)IP地址
- 采用 :ref:`thin_jail_using_nullfs` 来节约磁盘使用并方便统一更新基础部分 

.. note::

   本文记录完整部署步骤，也就是从主机激活Jail功能开始到通过辅助脚本快速启动jail

主机激活 jail
===============

- 执行以下命令配置在系统启动时启动 ``Jail`` :

.. literalinclude:: vnet_thin_jail/enable
   :caption: 激活jail

Jail目录树
=============

.. note::

   Jail文件的位置没有规定，在FreeBSD Handbook中采用的是 ``/usr/local/jails`` 目录。由于笔记本电脑只有一块硬盘，所以当安装FreeBSD并使用 :ref:`zfs` 作为根文件系统时，默认 ``zpool`` 是 ``zroot`` 。所以我为Jail选择的目录是 ``/zroot/jails`` 。

   我使用了 ``jail_zfs`` 环境变量来指定ZFS位置，对应目录就是 ``/$jail_zfs``

- 创建jail目录结构

.. literalinclude:: vnet_thin_jail/dir
   :caption: jail目录结构

.. note::

   - ``media`` 将包含已下载用户空间的压缩文件
   - ``templates`` 在使用 Thin Jails 时，该目录存储模板(共享核心系统)
   - ``containers`` 将存储jail (也就是容器)

``模板和NullFS`` 型
================================================

FreeBSD Thin Jail是基于 ZFS ``快照(snapshot)`` 或 ``模板和NullFS`` 来创建的 瘦 Jail:

  - ``快照(snapshot)`` 型: 快照只读的，不可更改的 - 这意味着 **没有办法简单通过更新共享的ZFS snapshot来实现Thin Jail操作系统更新**
  - ``模板和NullFS`` 型: 可以通过 **直接更新NullFS底座共享的ZFS dataset可以瞬间更新所有Thin Jail**

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

- 执行以下命令创建软连接:

.. literalinclude:: vnet_thin_jail/link
   :caption: 创建软连接

- **在host上执行** 修复 ``/etc/ssl/certs`` 目录下证书文件软链接

.. literalinclude:: vnet_thin_jail/fix_link.sh
   :caption: 修复软链接

- 在 ``skeleton`` 就绪之后，需要将数据复制到 jail 目录(如果是UFS文件系统)，对于ZFS则非常方便使用快照:

.. literalinclude:: thin_jail_desktop/snapshot
   :caption: 创建skeleton快照,然后再创建快照的clone(jail)

- 创建一个 ``base`` template的目录，这个目录是 ``skeleton`` 挂载所使用的根目录

 .. literalinclude:: thin_jail_desktop/nullfs-base
    :caption: 创建 ``skeleton`` 挂载所使用的根目录

配置jail
============

.. note::

   - Jail的配置分为公共部分和特定部分，公共部分涵盖了所有jails共有的配置
   - 尽可能提炼出Jails的公共部分，这样就可以简化针对每个jail的特定部分，方便编写较稳维护

- 创建所有jail使用的公共配置部分 ``/etc/jail.conf`` :

.. literalinclude:: thin_jail_desktop/jail.conf
   :caption: 所有jail使用的公共配置部分 ``/etc/jail.conf``

.. note::

   我实践发现，上述 ``jail.conf`` 配置中需要添加:

   .. literalinclude:: vnet_thin_jail/jail.conf_allow.mount
      :caption: 在jail.conf中添加 ``allow.mount`` 权限

   如果没有添加上述3行配置，那么jail中 ``df -h`` 就只能看到根目录:

   .. literalinclude:: vnet_thin_jail/jail.conf_no_allow.mount_df
      :caption: **没有** 配置配置允许挂载的时候

   而添加了允许挂载的权限之后才真的看到 ``devfs`` 被挂载上，而且 ``/skeleton`` 也被挂载上

   .. literalinclude:: vnet_thin_jail/jail.conf_allow.mount_df
      :caption: 配置配置允许挂载的时候
      :emphasize-lines: 3,4

- ``/etc/jail.conf.d/mdev.conf`` 独立配置部分:

.. literalinclude:: thin_jail_desktop/mdev.conf
   :caption: ``/etc/jail.conf.d/mdev.conf``

.. note::

   这里独立部分的 ``mdev.conf`` 内容是空的，仅仅提供了一个主机名。如果需要进一步配置，可以参考 :ref:`zfs-jail` 添加ZFS卷集

- 注意，这里配置引用了一个针对nullfs的fstab配置，所以还需要创建一个 ``/zroot/jails/mdev-nullfs-base.fstab`` :

.. literalinclude:: thin_jail_desktop/fstab
   :caption: ``/zroot/jails/mdev-nullfs-base.fstab``

- 最后启动 ``mdev`` :

.. literalinclude:: thin_jail_desktop/start
   :caption: 启动 ``mdev``   

通过 ``rexec mdev`` 进入jail

- 设置Jail ``mdev`` 在操作系统启动时启动，修改 ``/etc/rc.conf`` :

.. literalinclude:: thin_jail_desktop/rc.conf
   :caption: ``/etc/rc.conf``
