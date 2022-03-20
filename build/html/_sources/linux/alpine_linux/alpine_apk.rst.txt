.. _alpine_apk:

========================
Alpine Linux包管理apk
========================

apk软件仓库
================

``/etc/apk/repositories`` 配置文件中包含了软件仓库配置，默认是::

   /media/sdb1/apks

检查 ``/media/sdb1/apks`` 目录可以看到有一个子目录 ``x86_64`` ，在这个子目录下，有当前ISO镜像包含的本地常用的 ``.apk`` 软件包，也就是，即使没有互联网，通过 ``apk`` 命令就可以直接从这些本地软件包进行安装。

不过，如果要安装的软件包不在本地，需要通过因特网安装，则需要添加仓库配置。

从 https://mirrors.alpinelinux.org/ 可以获得官方Alpine Linux镜像网站，选择一个添加到配置 ``/etc/apk/repositories`` 中:

.. literalinclude:: alpine_apk/repositories
   :language: bash
   :linenos:
   :caption: 激活community仓库
   :emphasize-lines: 3

.. note::

   根据 ``/etc/alpine-release`` 配置可以知道本机的版本，所以对应选择 ``v3.14``

   ``main`` 只包含基础软件包，很多软件包都位于 ``community`` ，例如 ``libvirt-daemon`` / ``docker`` 等虚拟化软件

更新系统
==============

- 配置了软件仓库之后，就可以更新软件包列表::

   apk update

此时会提示信息::

   fetch http://mirror.math.princeton.edu/pub/alpinelinux/v3.14/main/x86_64/APKINDEX.tar.gz
   3.14.2 [/media/sdb1/apks]
   v3.14.2-5-gd4163d4c6c [http://mirror.math.princeton.edu/pub/alpinelinux/v3.14/main]
   OK: 4791 distinct packages available

- 然后可以更新系统::

   apk upgrade

也可以结合上述两个命令成一个命令::

   apk -U upgrade

- 如果只更新指定软件(例如busybox)，则使用::

   apk update
   apk add --upgrade busybox

diskless模式更新内核
-----------------------

由于 ``diskless`` 模式是只读设备(或ISO镜像)，不能直接更新boot文件，所以需要通过 ``setup-bootable`` 准备一个可写入boot设备

- 添加 mkinitfs 包::

   apk add mkinitfs

如果要支持特殊文件系统，例如 ``btrfs`` ，则需要在 ``/etc/mkinitfs/mkinitfs.conf`` 中激活，然后再执行 ``lbu commit`` ::

   ls /etc/mkinitfs/features.d
   apk add nano
   nano /etc/mkinitfs/mkinitfs.conf
   lbu commit

- 最后执行升级内核和boot环境::

   update-kernel /media/sdXY/boot/

添加软件包
=============

使用 ``add`` 可以从软件仓库安装一个软件包，所有依赖的软件包也会同时安装。如果有多个仓库，则 ``add`` 命令会安装最新的 软件包::

   apk add openssh
   apk add openssh openntp vim

默认只使用 ``main`` 仓库，软件是非常核心的，通常会同时激活 ``community`` 仓库，见上文。

如果只是想从 ``edge/testing`` 仓库安装一个软件包，但是不修改软件仓库配置，可以使用如下命令::

   apk add cfssl --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

这里仓库名见上文repo配置。这里案例是 :ref:`alpine_cfssl`

基础软件安装
==================

- 默认最小化安装对于维护不是很方便，所以安装以下软件::

   # NFS客户端和服务
   apk add nfs-utils
   # 磁盘维护
   apk add lsblk cfdisk e2fsprogs
   # lspci等维护工具
   apk add pciutils


参考
========

- `Alpine Linux package management <https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management>`_
