.. _alpine_install:

=======================
安装Alpine Linux
=======================

.. note::

   在 :ref:`alpine_startup` 之后，我决定采用 ``extended`` 模式来构建我的集群计算节点。本文为安装实践记录。

最小硬件要求
================

- 内存: alpine linux字符模式对内存要求100MB，如果是图形桌面则内存要求大大增加，可能会要求至少1GB。我经过考虑到性能最大化，不部署任何多余软件，不安装桌面系统。
- 硬盘: 根据安装模式不同需要 0-700MB 可写入磁盘空间(只在 ``sys`` 和 ``data`` 模式需要可写磁盘空间)，在 ``diskless`` 模式只需要保存一些较新和配置状态数据

.. note::

   我采用 ``extended`` 模式运行Alpine Linux，实际上可以不使用内置硬盘，而是采用非常廉价的外接U盘运行，这样随时可以更换故障节点，无需重装。(当然这也和我规划的 :ref:`priv_cloud_infra` 相关)

   我选择采用非常小巧的SanDisk CZ430 酷豆U盘，规格32G，只需要 37.90元。

   .. figure:: ../../_static/linux/alpine_linux/sandisk_udisk_32g.png
      :scale: 50
  
安装介质
==============

alpine linux提供了 ISO 安装镜像文件，对于主机，只需要刻录光盘，从光盘启动即可开始安装。不过，对于单板计算机(single-board-computer, SBC)架构，如树莓派，不能从 ``.iso`` 镜像启动，需要下载 ``Alpine for Raspberry Pi tarball`` 进行手工安装，详细请参考(我还没有实践):

- `Alpine Linux Raspberry Pi <https://wiki.alpinelinux.org/wiki/Raspberry_Pi>`_
- `Raspberry Pi 4 - Persistent system acting as a NAS and Time Machine <https://wiki.alpinelinux.org/wiki/Raspberry_Pi_4_-_Persistent_system_acting_as_a_NAS_and_Time_Machine>`_

对于 ``x86`` 系统安装非常简便，可以将ISO文件 ``dd`` 到U盘，从U盘启动安装::

   sudo dd if=alpine-extended-3.14.1-x86_64.iso of=/dev/sdb bs=100M

启动系统后，直接进入字符界面，以 ``root`` 用户登陆，默认没有密码 (后续在 ``setup-alpine`` 交互过程中会配置，见下文)

setup-alpine
==============

Alpine Linux使用 ``setup-alpine`` 交互脚本来配置、安装整个初始化Alpine Linux系统。

``setup-alpine`` 可以配置安装启动进入3种不同的磁盘模式:

- ``diskless``
- ``data``
- ``sys``

如果在 ``setup-alpine`` 交互中选择了 ``none`` 来回答 ``使用哪个磁盘`` 这个问题，就会进入 ``disk-less`` 磁盘模式。在 ``diskless`` 模式虽然没有配置磁盘，但是依然可以通过运行 ``setup-lbu`` 和 ``setup-apkcache`` 来添加持久化配置和软件包缓存存储。然后，可以通过 ``lbu commit`` 来保存系统状态。或者使用 ``setup-disk`` 命令来添加一个 ``data`` 模式分区，甚至可以执行一个传统的完整安装将 ``diskless`` 系统安装到一个 ``sys`` 磁盘或分区。

.. note::

   我非常看好这个 ``diskless`` 模式，本地无磁盘，通过 :ref:`ceph` 提供的 RBD 块设备实现分布式存储，这样可以获得高性能、高可用性

磁盘模式详解
----------------

``diskless`` 模式
~~~~~~~~~~~~~~~~~~~~~~

``diskless`` 模式是.iso镜像启动的默认模式。在 ``setup-alpine`` 的安装配置过程中国呢，如果选择了 ``disk=none`` 就会采用 ``diskless`` 模式。这意味着整个操作系统以及所有应用程序都被加载到内存中并在内存中运行。这种模式非常快并且可以节约不必要的磁盘、电力以及损耗。

用户定制的配置和安装软件包可能可以通过Alpine本地备份工具 ``lbu`` 在重启之后恢复。这是通过commit和revert系统状态，使用 ``.apkovl`` 文件保存到可写入存储并在启动时加载。如果添加或更新软件包到系统中，可以通过在可写入存储中激活一个 ``本地包缓存`` ( ``local package cache`` )可能可以在启动过程中自动重新安装。

.. note::

   将配置和软件包缓存存储到主机内部存储磁盘，则还会需要一些手工步骤来获得分区信息，例如配置 ``/etc/fstab`` 挂载点，以及挂载。这个过程需要在运行 ``setup-alpine`` 之前完成。
   
   例如，手工编辑 ``/etc/lbu/lub.conf`` 设置::

      LBU_MEDIA=sdXY

    然后执行相应的命令::

       echo "/dev/sdXY /media/sdXY vfat rw 0 0" >> /etc/fstab

    最后在执行::

       lbu commit

    来配置分区在启动时挂载。

    上述步骤我将实践并记录。

为了允许本地备份， ``setup-alpine`` 可以告知系统将配置和包缓存存储到一个可写入分区。例如将分区挂载到 ``/home`` 目录或者重要的应用程序的run-time和用户数据。

``data`` 模式
~~~~~~~~~~~~~~~~~~

在 ``data`` 模式下，整个系统也是复制到内存中，然后再运行，所以操作和运行速度和 ``diskless`` 模式是一样的。但是，swap存储和整个 ``/var`` 分区是挂载持久化存储设备来实现的。这里 ``/var`` 目录可以用来存储日志，邮件，数据库等等，就像 ``lbu`` 备份commit。

在 ``data`` 模式可以充分使用内存来加速系统运行，同时用户数据持久化存储不会丢失。配置方法类似上文 ``diskless`` 配置磁盘。

``sys`` 模式
~~~~~~~~~~~~~~~~~

``sys`` 模式就是传统的磁盘安装模式。 ``setup-alpine`` 脚本会在主机内置磁盘上创建3个分区： ``boot`` , swap 和 ``/`` (根文件系统)。

安装镜像刷磁盘
===================

在 linux 或 macOS 中，可以通过 ``dd`` 命令将安装镜像刷入到U盘，然后进行上述运行和安装操作:

.. literalinclude:: alpine_install/dd
   :caption: 安装U

(可选)检查iso文件和安装磁盘一致性::

   cmp ~/Downloads/alpine-standard-3.00.0-x86_64.iso /dev/sdX

启动
==========

通过外接上述制作的U盘启动系统，然后执行 ``setup-alpine`` 配置磁盘。

如果配置 ``sys`` 磁盘模式，则设置完成后就可以重启系统。

如果配置 ``diskless`` 或 ``data`` 模式，并且你不希望始终从初始安装介质(U盘)启动系统，则需要将 ``boot`` 系统复制到其他设备或分区。你可以通过 ``lsblk`` 命令 (通过 ``apk add lsblk`` 添加) 或 ``blkid`` 命令来标识安装介质。

然后执行::

   setup-bootable

就可以将boot系统复制

注意，完成上述工作后，请执行  ``lbu commit`` 来保存配置，之后才能重启。

参考
=====

- `Alpine Linux handbook: Installing <https://docs.alpinelinux.org/user-handbook/0.1a/Installing/setup_alpine.html>`_
- `Alpine Linux wini: Installation <https://wiki.alpinelinux.org/wiki/Installation>`_
