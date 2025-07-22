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

- 设置环境变量:

.. literalinclude:: vnet_thin_jail/env
   :caption: 设置 jail目录和release版本环境变量

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

  - ZFS snapshot Thin Jail: 将FreeBSD Release base存放在 **只读** 的 ``14.3-RELEASE@base`` 快照上
  - NullFS Thin Jail: 将FreeBSD Release base存放在 **读写** 的 ``14.3-RELEASE-base`` 数据集上

通过结合Thin Jail 和 ``NullFS`` 技术可以创建节约文件系统存储开销(类似于 ZFS ``snapshot`` clone出来的卷完全不消耗空间)，并且能够将Host主机的目录共享给 **多个** Jail。

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

这里有一个疑惑，我的host主机 :ref:`freebsd_update_upgrade` 从 ``14.3-RELEASE`` 升级到 ``14.3-RELEASE`` ，这时我使用 ``$bsd_ver-RELEASE/base.txz`` 下载的 ``14.3-RELEASE/base.txz`` ，解压缩以后使用上面的命令进行更新，输出的提示信息

.. literalinclude:: vnet_thin_jail/update_output
   :caption: 更新模版补丁时候的输出信息显示是 ``14.3-RELEASE-p0``
   :emphasize-lines: 3,8

可以看到host主机对模版更新是自动按照 ``14.3-RELEASE`` 的元数据进行，而不是模版的 ``14.3-RELEASE`` 。那么jail模版现在是 ``14.3-RELEASE`` 么？

- 创建一个特定数据集 ``skeleton`` (**骨骼**) ，这个 "骨骼" ``skeleton`` 命名非常形象，用意就是构建特殊的支持大量thin jial的框架底座

.. literalinclude:: vnet_thin_jail/zfs_create
   :caption: 创建skeleton

- 执行以下命令，将特定目录移入 ``skeleton`` 数据集，并构建 ``base`` 和 ``skeleton`` 必要目录的软连接关系

.. literalinclude:: vnet_thin_jail/skeleton_link
   :caption: 特定目录移入 ``skeleton`` 数据集

.. note::

   按照handbook，是执行 ``mv /$jail_zfs/templates/$bsd_ver-RELEASE-base/var /$jail_zfs/templates/$bsd_ver-RELEASE-skeleton/var`` 有如下报错:

   .. literalinclude:: vnet_thin_jail/skeleton_link_error
      :caption: 报错

   这是因为  ``var/empty`` 目录没有权限删除: ``mv var/empty: Operation not permitted`` ，所以我采用 ``rsync`` 方法workround绕过(见上文)。

   我之前有一个错误的步骤，我先采用了 ``mv var`` 报错以后，再使用 ``mv var var.bak`` 来修复，也就是执行了如下命令:

   .. literalinclude:: vnet_thin_jail/skeleton_link_fix
      :caption: **错误的mv方法** 我发现目标var目录损坏了

   所以必须使用类似 ``rsync`` 的命令先复制好var目录，然后再移除原来的var方便后续建立link

- 执行以下命令创建软连接:

.. literalinclude:: vnet_thin_jail/link
   :caption: 创建软连接

.. warning::

   我在实践NullFS的Thin Jails，发现移动到 ``skeleton`` 目录下的 ``/etc`` 目录有一个子目录 ``/etc/ssl/certs`` 。这个证书目录下的文件是软链接到 ``../../../usr/share/certs/trusted/`` 目录下的证书文件。由于 ``/etc`` 目录移动后会导致这些相对链接失效，所以需要有一个修复软链接的步骤。

   如果不执行这个证书软链接修复，则后续host主机上执行 ``pkg -j <jail_name> install <package_name>`` 会报错；而在jail中执行 ``pkg`` 命令会显示证书相关错误:

   .. literalinclude:: vnet_thin_jail/pkg_error
      :caption: 在jail中执行 ``pkg`` 命令会显示证书相关错误

- **在host上执行** 修复 ``/etc/ssl/certs`` 目录下证书文件软链接

.. literalinclude:: vnet_thin_jail/fix_link.sh
   :caption: 修复软链接

.. note::

   我最初是在运行的NullFS thin jail上执行 :ref:`jail_init` 发现报错:

   .. literalinclude:: jail_init/install_error
      :caption: 安装报错

   在jail内部尝试运行 ``pkg install sudo`` ，发现需要更新 ``pkg`` ，但是似乎 ``/usr/src`` 目录导致错误:

   .. literalinclude:: jail_init/install_error_in_jail
      :caption: 在jail内部安装报错

   原来是 ``NullFS`` 的Thin Jail构建的移动 ``/etc`` 目录到 ``skeleton/etc`` 之后，所有在 ``/etc/ssl/certs`` 目录下原先的软连接到 ``../../../usr/share/certs/trusted/`` 目录下的证书的连接全部失效了。非常奇怪:

   .. literalinclude:: jail_init/link_error
      :caption: ``/etc/ssl/certs`` 目录下软连接失效

   原因找到了，是因为原先 ``/etc/ssl/certs/`` 目录下的软链接都是相对链接，当 ``/etc`` 目录被移动到 ``skeleton`` 目录下之后，这个相对软链接就失效了。所以就有了上述修复脚本来完成软链接修正。

   修复以后 ``skeleton/etc/ssl/cets/`` 目录下的软链接应该类似如下:

   .. literalinclude:: jail_init/link_ok
      :caption: 修复以后的软链接

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
