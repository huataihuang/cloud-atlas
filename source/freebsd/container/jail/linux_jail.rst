.. _linux_jail:

======================
FreeBSD Linux Jail
======================

.. note::

   我之前曾经实践过 :ref:`linux_jail_archive` ，但是当时经验不足折腾了很久记录也比较杂乱。最近我准备构建一个在FreeBSD系统编译 :ref:`lfs` ，也就是通过Linux Jail模拟出一个Linux环境，来访问和FreeBSD共存的Linux分区，通过这个模拟linux jail来编译LFS。

   本文是重新实践的笔记，我将采用ZFS存储上构建 :ref:`vnet_thin_jail_snapshot` 基础上部署linux jail:

   我最初想采用 :ref:`vnet_thin_jail` ，但是在挂载Linux根目录时遇到了和NullFS根目录挂载的冲突(为避免资源死锁，拒绝挂载)，仔细看了官方手册发现官方案例是Snapshot类型的Thin Jail，所以改为采用 :ref:`vnet_thin_jail_snapshot`

.. warning::

   由于本次实践是在FreeBSD 15 Alpha 2上进行，遇到了好几个坑:

   - 不支持在ZFS存储上存放 ``/compat/ubuntu`` 系统(应该是现阶段的bug，之前RELEASE版本是正常的)
   - ``bootstrap`` 不能正确创建Ubuntu工作环境( 最后通过 :ref:`linux_jail_ubuntu-base` 绕过问题)

   不过，本文的方法步骤是正确的，相信再过几个月(2025年12月会发布FreeBSD 15 RELEASE)正式版本发布以后就可以了。

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

快照(snapshot)型Thin Jails
----------------------------------

.. note::

   :ref:`snapshot_vs_templates_nullfs_thin_jails`

   实践发现需要采用 ``Snapshot Thin Jail``

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

   我的最近一次实践是在 ``15.0-ALPHA2`` 上运行 ``14.3-RELEASE`` Jail，由于 ``freebsd-update`` 不支持ALPHA，则更新会报错(同 :ref:`freebsd_15_alpha_update_upgrade` ):

   .. literalinclude:: ../../admin/freebsd_15_alpha_update_upgrade/fetch_error
      :caption: 在FreeBSD 15 Alpha 2 上执行 ``freebsd-update`` 报错
      :emphasize-lines: 9,13

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

配置Snapshot Thin Jails
----------------------------

.. note::

   先Thin Jail ，运行起来以后再调整为Linux Jail

   - Jail的配置分为公共部分和特定部分，公共部分涵盖了所有jails共有的配置
   - 尽可能提炼出Jails的公共部分，这样就可以简化针对每个jail的特定部分，方便编写校验维护

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

Linux Jail
==============

Linux Jail是在常规Jail上启用 Linux ABI实现

- 首先激活启动时Linux ABI支持:

.. literalinclude:: linux_jail/enable
   :caption: 激活启动时Linux ABI支持

- 一旦激活，就可以执行以下命令无需重启系统:

.. literalinclude:: linux_jail/start
   :caption: 启动Linux ABI支持

启动Linux支持后，在 FreeBSD Host 上执行 ``df`` 可以看到系统挂载了Linux兼容的设备文件系统:

.. literalinclude:: linux_jail/df
   :caption: FreeBSD Host 上Linux兼容的设备文件系统

- 现在进入 ``ldev`` 容器:

.. literalinclude:: linux_jail/jexec
   :caption: 进入 ``ldev`` 容器 

- 在jail内部执行以下命令安装 ``sysutils/debootstrap`` 以便安装 :ref:`ubuntu_linux` 环境:

.. literalinclude:: linux_jail/debootstrap
   :caption: 安装 ``debootstrap`` 部署Ubuntu

完成后观察Linux Jail中文件系统挂载，可以看到增加了一个 ``devfs`` 挂载到 ``/compat/ubuntu/dev`` :

.. literalinclude:: linux_jail/df_in_linux_jail
   :caption: 在Linux Jail内部查看文件系统挂载
   :emphasize-lines: 5

.. note::

   所有 ``debootstrap`` 使用的脚本都存储在 ``/usr/local/share/debootstrap/scripts/`` 目录，目前只支持 Ubuntu 22.04 (jammy)。如果要安装更高版本，请参考 :ref:`linux_jail_ubuntu-base`

- 暂时停止 ``ldev`` jail:

.. literalinclude:: linux_jail/stop
   :caption: 停止 jail

- 修订 ``/etc/jail.conf.d/ldev.conf`` 添加挂载配置:

.. literalinclude:: linux_jail/ldev_mount.conf
   :caption: 为 ``/etc/jail.conf.d/ldev.conf`` 添加挂载配置
   :emphasize-lines: 13-19

- 然后启动 ``ldev`` :

.. literalinclude:: linux_jail/start
   :caption: 启动Linux ABI支持

- 进入Linux Jail的Ubuntu环境(需要结合 ``chroot`` ):

.. literalinclude:: linux_jail/jexec_chroot
   :caption: 进入Linux Jail的Ubuntu环境

- 在Linux Jail Ubuntu中执行以下 ``uname`` 命令检查环境:

.. literalinclude:: linux_jail/uname
   :caption: ``uname`` 命令检查Linux环境

输出显示如下:

.. literalinclude:: linux_jail/uname_output
   :caption: ``uname`` 命令检查Linux环境的输出

异常排查
==========

- 执行 ``jexec ubuntu chroot /compat/ubuntu /bin/bash`` 进入了Linux Jail Ubuntu环境，但是提示一个错误信息，显示没有组ID，确实发现在Linux Jail中的 ``/etc/`` 目录下没有 ``passwd`` 和 ``group`` 文件

.. literalinclude:: linux_jail/not_found_gid
   :caption: 进入Linux Jail Ubuntu环境提示没有找到组ID
   :emphasize-lines: 2,3,6,11

解决的方法是在FreeBSD Host主机上，将Host主机的 ``/etc/group`` 和 ``/etc/passwd`` 文件复制到Linux Jail中:

.. literalinclude:: linux_jail/cp_group
   :caption: 在FreeBSD Host主机上复制 ``/etc/group``

- 另外，在 ``ls`` 命令执行时总是提示 ``Invalid argument`` :

.. literalinclude::  linux_jail/invalid_argument
   :caption: 任何 ``ls`` 都提示 ``Invalid argument``
   :emphasize-lines: 2

比较奇怪，虽然 ``debootstrap`` 显示安装了 ``apt 2.4.5`` ，但是我 ``chroot /comapt/ubuntu /bin/bash`` 之后却显示找不到 ``apt`` 命令

我检查发现，在 Linux Jail Ubuntu的 chroot 目录后， ``/var/cache/apt/archives`` 目录下实际上已经下载了需要安装的软件包，但是却没有安装。我手工尝试安装:

.. literalinclude:: linux_jail/dpkg_apt
   :caption: 通过 ``dpkg`` 手工安装 ``apt`` 包

看出了异常，连目录不能读取出现报错:

.. literalinclude:: linux_jail/dpkg_apt_output
   :caption: 通过 ``dpkg`` 手工安装 ``apt`` 包报错信息

实际上目录是存在的，但是无法读取:

.. literalinclude:: linux_jail/read_directory_invalid_argument
   :caption: 读取目录报错
   :emphasize-lines: 3,5

正是这个目录无法读取的报错，导致了一系列apt软件包(包括自己)都没有安装成功

我回顾了以下自己的操作步骤，发现有一步是我自作主张和手册不同的，就是我首次启动 ``ldev`` Snapshot Thin Jail使用了自己之前在 :ref:`vnet_thin_jail_snapshot` 的配置文件，而不是手册中的命令行方式，我怀疑是这个步骤差异导致了Linux兼容层安装失败(实践验证并不是)

对比手册初次启动Thin Jail命令:

.. literalinclude:: linux_jail/jail_run
   :caption: 手册启动Thin Jail命令(按照我的环境做了一些修改)
   :emphasize-lines: 13-17

对比了配置文件，主要差别就是上述高亮的权限没有允许，我尝试修订配置文件添加上述权限允许。然而很不幸，再次启动 ``ldev`` 并没有解决问题。而且我发现实际上添加前后，进入 ``ldev`` (尚未chroot)，在FreeBSD Thin Jail中看到挂载虚拟文件系统是一样的，说明这些权限添加不添加都没有关系。再看手册中配置案例也没有添加，所以我还是去除这些配置:

.. literalinclude:: linux_jail/ldev_jail_df
   :caption: 在 ``ldev`` 中检查 ``df -h`` 可以看到已经挂载了Linux需要的文件系统
   :emphasize-lines: 5-12

google gemini提示是 Linux执行程序和FreeBSD内核提供的Linux兼容层存在功能不匹配，通常是文件系统metadata相关的翻译问题，或者是 **目录包含的属性Linux二进制程序不能识别** 。

我忽然想到我在底层的ZFS上启用了压缩属性，会不会导致上述问题?

在 FreeBSD Host 主机上检查:

.. literalinclude:: linux_jail/host_zfs_ldev
   :caption: 检查 ``ldev`` 所在ZFS卷属性

输出显示这个ZFS dataset继承了上一级ZFS的压缩属性:

.. literalinclude:: linux_jail/host_zfs_ldev_output
   :caption: 检查 ``ldev`` 所在ZFS卷属性可以看到继承了上级ZFS的压缩属性

回滚步骤，重新开始创建 ``ldev`` linux jail所使用的ZFS卷，也就是clone步骤:

.. literalinclude:: vnet_thin_jail_snapshot/clone_ldev
   :caption: clone出一个名为 ``ldev`` 的Thin Jail(后续将进一步改造为 :ref:`linux_jail` )

这步完成后立即执行关闭压缩:

.. literalinclude:: vnet_thin_jail_snapshot/zfs_disable_compression
   :caption: 关闭clone出来的ZFS卷的compression属性

然后检查关闭情况:

.. literalinclude:: vnet_thin_jail_snapshot/check_zfs_compression
   :caption: 检查ZFS的压缩关闭

可以看到已经off

.. literalinclude:: vnet_thin_jail_snapshot/check_zfs_compression_output
   :caption: 检查ZFS的压缩关闭确保已经off

然后重新创建 ``ldev``

**悲伤，没有解决这个问题，报错依旧**

UFS文件系统上Linux Jail
===========================

那如果ZFS始终存在上述问题，是否改成UFS能够绕开呢？好吧，那就再搞一次 :ref:`vnet_thick_jail` ( :ref:`thin_jail` 需要 :ref:`zfs` 支持，所以改为UFS的话需要采用 Classic Jail ，也就是 :ref:`thick_jail` )

- 执行 :ref:`vnet_thick_jail` 部署

- 按照上文启动 ``ludev`` Jail之后，通过 ``jexec ludev`` 进入Jail执行 ``debootstrap`` :

.. literalinclude:: linux_jail/debootstrap
   :caption: 安装 ``debootstrap`` 部署Ubuntu

注意到工具接收到安装包进行校验，然后 ``Extracting`` 软件包:

.. literalinclude:: linux_jail/debootstrap_output
   :caption: ``debootstrap`` 输出信息

- 暂停 ``ludev`` Jail，并修订 ``/etc/jail.conf.d/ludev.conf`` 添加Linux文件系统挂载部分:

.. literalinclude:: linux_jail/ludev.conf
   :caption: 添加Linux文件系统挂载
   :emphasize-lines: 13-19

- 再次启动 ``ludev`` Jail，然后进入Linux Jail的Ubuntu环境:

.. literalinclude:: linux_jail/jexec_chroot_ludev
   :caption: 进入Linux Jail的Ubuntu环境

.. note::

   将底层文件系统切换到UFS之后，确实解决了 ``Invalid argument`` 的报错问题，此时 ``chroot`` 进入Ubuntu系统后， ``ls`` 命令不再报错

比较奇怪的是，在这个 Ubuntu Jail环境中，默认没有安装apt工具包，但是在 ``/var/cache/apt/archives`` 目录下却有很多下载的 ``deb`` 软件包，也包括 ``apt-utils_2.4.5_amd64.deb  apt_2.4.5_amd64.deb``

我尝试在 ``/var/cache/apt/archives`` 手工先安装 ``apt`` 工具以便后面再补充软件包:

.. literalinclude:: linux_jail/install_apt
   :caption: 安装apt工具包

上述安装命令依然报依赖错误，我一狠心，直接执行了 ``dpkg -i *.deb`` ，看起来很多软件包安装成功，但是也有大量软件包报告依赖安装错误，特别是 :ref:`systemd` 相关。我知道在Linux Jail中是不支持systemd的，看起来这个 ``debootstrap`` 下载了很多依赖安装包是不能直接安装的，有可能会误安装了 systemd 相关软件包导致异常。

不过， ``dpkg -i *.deb`` 确实也安装成功了 ``apt`` 软件，只不过系统误安装了 ``systemd`` 相关软件后(实际安装失败，但是残留了很多包信息)，导致混乱而无法进一步更新系统。

**我感觉应该安装一个类似Docker容器中运行的Ubuntu版本，这样精简过的系统可以剔除systemd干扰** ，准备尝试 :ref:`linux_jail_ubuntu-base`

.. note::

   :ref:`linux_jail_init`

参考
======

- `FreeBSD Handbook: Chapter 17. Jails and Containers <https://docs.freebsd.org/en/books/handbook/jails/>`_
- `(Solved)How to have network access inside a Linux jail? <https://forums.freebsd.org/threads/how-to-have-network-access-inside-a-linux-jail.76460/>`_ 这个讨论非常详细，是解决Linux Jail普通用户网络问题的线索
- `(Solved)No internet access from inside jail! <https://forums.freebsd.org/threads/no-internet-access-from-inside-jail.78576/>`_
- `ping as non-root fails due to missing capabilities #143 <https://github.com/grml/grml-live/issues/143>`_ 
- `Setting up a (Debian) Linux jail on FreeBSD <https://forums.freebsd.org/threads/setting-up-a-debian-linux-jail-on-freebsd.68434/>`_ 一篇非常详细的Linux Jail实践

