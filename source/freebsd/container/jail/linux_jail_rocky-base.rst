.. _linux_jail_rocky-base:

===========================================================
使用 ``Rocky-Container-base`` tgz 包部署Linux Jail Rocky
===========================================================

说明
======

我在 :ref:`linuxulator_nvidia_cuda` 实践中遇到执行 ``miniconda-installer`` 运行报错，推测和Python3运行环境相关。想对比尝试 :ref:`linuxulator_startup` 中更新 ``linuxulator`` 中 Rocky Linux 9 的Python(系统提供的 ``linux-rl9`` 中python配置有问题)。但是发现发行版的 ``linuxulator`` linux userland实际上是非常非常精简的系统，甚至没有提供 :ref:`dnf` 包管理器。

考虑到 ``linuxulator`` 和 :ref:`linux_jail` 实际底层原理一致，既然 :ref:`linux_jail_ubuntu-base` 能够通过Ubuntu core来构建，那么Rocky Linux应该也可以以相同方式构建 ``linuxulator`` userland 环境。

同理，也可以使用 ``Rocky-9-Container-base`` 来构建 :ref:`linux_jail` ，就像 :ref:`linux_jail_ubuntu-base` 一样。这样思路打开了，完全可以构建不同Linux发行版的 Linux Jail 或 ``linuxulator``

`Rocky Linux download > 9 > images > x86_64 <https://download.rockylinux.org/pub/rocky/9/images/x86_64/>`_ 提供了 `Rocky-9-Container-base.latest.x86_64.tar.xz <https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-base.latest.x86_64.tar.xz>`_ ，虽然是针对 :ref:`container` 的镜像压缩包，但是jail非常类似container，实际上都剥离了 :ref:`systemd` ，应该可以共用。

Linux Jail
=============

FreeBSD Linux Jail是在FreeBSD Jail中激活支持Linux二进制程序的一种实现，通过一个允许Linux系统调用和库的兼容层来实现转换和执行在FreeBSD内核上。这种特殊的Jail可以无需独立的linux虚拟机就可以运行Linux软件。

VNET + Thin Jail(Snapshot)
============================

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

快照(snapshot)
-------------------

.. note::

   :ref:`snapshot_vs_templates_nullfs_thin_jails` 说明两种不同的Thin Jail，本文是 OpenZFS Snapshots 类型的Thin Jail构建记录:

   - ZFS snapshot Thin Jail: 将FreeBSD Release base存放在 **只读** 的 ``14.3-RELEASE@base`` 快照上
   - NullFS Thin Jail: 将FreeBSD Release base存放在 **读写** 的 ``14.3-RELEASE-base`` 数据集上

   在 Linux Jail 中采用 ``ZFS snapshot Thin Jail`` 是为了避免复杂的 ``RELEASE-base`` 分离以及NullFS挂载 对Linux文件系统挂载的冲突影响。

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

.. literalinclude:: linux_jail_rocky-base/jail_name
   :caption: 为了能够灵活创建jail，这里定义一个 ``jail_name`` 环境变量，方便后续调整jail命名

.. literalinclude:: vnet_thin_jail_snapshot/clone_ldev
   :caption: clone出一个名为 ``lrdev`` 的Thin Jail(后续将进一步改造为 :ref:`linux_jail` )

- 现在可以看到相关ZFS数据集如下:

.. literalinclude:: linux_jail_rocky-base/df_jail
   :caption: ZFS数据集显示jail存储
   :emphasize-lines: 9

配置Jail
==========

.. note::

   在 :ref:`vnet_thin_jail` 配置基础上完成

- 适合不同Jail的公共配置 ``/etc/jail.conf`` :

.. literalinclude:: vnet_thin_jail/jail.conf_common
   :caption: 混合多种jail的公共 ``/etc/jail.conf``

- 用于Snapshot类型的 ``lrdev`` 独立配置 ``/etc/jail.conf.d/lrdev.conf`` :

.. literalinclude:: linux_jail_rocky-base/lrdev.conf
   :caption: 用于Snapshot类型 ``/etc/jail.conf.d/lrdev.conf``
   :emphasize-lines: 6

部署 Rocky 9
=================

在FreeBSD handbook中 `Chapter 12. Linux Binary Compatibility <https://docs.freebsd.org/en/books/handbook/linuxemu/>`_ 标准方法是采用 ``debootstrap`` 来构建userland，但是这个方法有2个不足:

- ``debootstrap`` 只能用来构建 :ref:`debian` 系的发行版userland
- 我在实践中发现 ``debootstrap`` 总有非常奇怪的不报错但是也没有完成完整的 ``.deb`` 包(已下载)安装的问题，导致实际构建的userland无法正常使用(也可能和我使用FreeBSD 15 Alpha版本有关)

实际上现在发行版大多数会提供 ``core-base`` tgz包，通常用于 :ref:`container` 容器。由于这种核心系统不包含 :ref:`systemd` ，并且FreeBSD Jail的原理和容器相似，所以也能用于构建FreeBSD Linux Jail的userland部分，即Linux系统。

.. note::

   对于 :ref:`redhat_linux` 系列发行版，也有类似 ``debootstrap`` 的工具用于获取base系统:

   - `rhbootstrap <https://github.com/serhepopovych/rhbootstrap>`_ 类似 ``debootstrap`` 用于 Rocky/CentOS/Fedora 系统构建bootstrap
   - ``rinse`` : 在debian上提供的一个获取并安装rpm包构建一个RedHat系系统的工具，在Ubuntu上帮助系统中有介绍 `rinse manual <https://manpages.ubuntu.com/manpages/noble/man8/rinse.8.html>`_ ，也可以参考 `Building an RPM based (Red Hat, Fedora, CentOS) Xen Guest Root Filesystem using Rinse <https://www.techotopia.com/index.php/Building_an_RPM_based_(Red_Hat,_Fedora,_CentOS)_Xen_Guest_Root_Filesystem_using_Rinse>`_
   - Kickstart: Red Hat系用来自动安装系统的复杂工具
   - Mock: 用于 :ref:`fedora` 和 :ref:`rockylinux` 构建包的chroot环，也可以用来构建一个类似 ``debootstrap`` 的包测试环境
   - Container Tools: :ref:`podman` 或 :ref:`docker` 使用的创建基本最小系统的工具，可以用来下载一个Rocky Linux镜像，并用它作为一个构建定制环境

我已经实践 :ref:`linux_jail_ubuntu-base` 构建了FreeBSD ``debootstrap`` 默认不支持的 Ubuntu 24.04 系统，验证这个方法是可行的。所以，这里也采用类似方法来构建 :ref:`rockylinux` userland。

.. note::

   不要使用 ``Rocky-9-Container-Minimal.latest.x86_64.tar.xz`` ，这个 ``minimal`` 版本不包含 :ref:`dnf` 包管理器，也就是说，实际上FreeBSD ``linuxulator`` 提供的userland其实就是 ``minimal`` 版本。

`Rocky Linux download > 9 > images > x86_64 <https://download.rockylinux.org/pub/rocky/9/images/x86_64/>`_ 提供了 `Rocky-9-Container-base.latest.x86_64.tar.xz <https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-base.latest.x86_64.tar.xz>`_ ，虽然是针对 :ref:`container` 的镜像压缩包，但是jail非常类似container，实际上都剥离了 :ref:`systemd` ，应该可以共用。

- 下载 `Rocky-9-Container-base.latest.x86_64.tar.xz <https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-base.latest.x86_64.tar.xz>`_

- 解压缩下载 ``Rocky-9-Container-Base.latest.x86_64.tar.xz`` :

.. literalinclude:: linux_jail_rocky-base/tar
   :caption: 解压缩

- 在FreeBSD Host主机上将 ``/etc/resolv.conf`` 复制给Jail使用:

.. literalinclude:: linux_jail_rocky-base/cp_resolv
   :caption: 将Host主机的 ``/etc/resolv.conf`` 复制给Jail

使用Linux Jail
=================

**一切就绪** 现在可以启动名为 ``lrdev`` 的Linux Jail

.. literalinclude:: linux_jail_rocky-base/start
   :caption: 启动 ``lrdev`` Linux Jail

- 进入 ``lrdev`` 的Linux环境:

.. literalinclude:: linux_jail_rocky-base/jexec
   :caption: 进入 ``lrdev`` 的Linux环境

- 更新:

.. literalinclude:: linux_jail_rocky-base/update
   :caption: 更新系统

- 安装 ``config-manager`` 插件(用于管理后续仓库配置):

.. literalinclude:: linux_jail_rocky-base/config-manager
   :caption: 安装 ``config-manager`` 插件

- (可选) :ref:`linux_jail_init_rocky`

参考
=======

- `Chapter 12. Linux Binary Compatibility <https://docs.freebsd.org/en/books/handbook/linuxemu/>`_
- `Davinci Resolve install on Freebsd using an Rocky Linux Jail <https://github.com/NapoleonWils0n/davinci-resolve-freebsd-jail-rocky>`_
