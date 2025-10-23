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

   根据 ``/etc/alpine-release`` 配置可以知道本机的版本，所以对应选择 ``v3.22`` (例如我现在2025年10月发行版)

   ``main`` 只包含基础软件包，很多软件包都位于 ``community`` ，例如 ``libvirt-daemon`` / ``docker`` 等虚拟化软件

   通常大多数软件不需要激活 ``edge`` 分支，

.. _alpine_upgrade_edge:

alpine linux升级到滚动版本 ``edge`` 
======================================

有些软件包属于testing状态，没有包含在默认的 ``main`` 和 ``commnity`` 仓库中，例如 :ref:`alpine_install_calibre` 就会遇到报错:

.. literalinclude:: alpine_apk/no_such_package
   :caption: 安装软件包没有包含在仓库中报错

`edge/testing仓库提供了 calibre软件包 <https://pkgs.alpinelinux.org/package/edge/testing/x86_64/calibre>`_ 

升级到 ``edge`` 版本进行安装(我试了同时添加stable和edge的仓库，安装edge仓库中软件包虽然能安装成功，但是运行会报库文件无法找到错误):

- 在 ``/etc/apk/repositories`` 修订成 ``edge/testing`` 仓库:

.. literalinclude:: alpine_apk/repositories_edge
   :caption: 在 ``/etc/apk/repositories`` 添加 ``edge/testing`` 仓库
   :emphasize-lines: 4-6

- 执行更新:

.. literalinclude:: alpine_apk/update_upgrade
   :caption: 一条命令完整更新alpine linux系统

完成后提示如下:

.. literalinclude:: alpine_apk/update_upgrade_output
   :caption: 大版本升级提示

- **正确步骤** 参考 https://alpinelinux.org/posts/2025-10-01-usr-merge.html 完成完成升级:

.. literalinclude:: alpine_apk/upgrade_edge
   :caption: 完整升级

更新系统
==============

- 配置了软件仓库之后，就可以更新软件包列表:

.. literalinclude:: alpine_apk/update
   :caption: 更新alpine linux的软件包列表

此时会提示信息:

.. literalinclude:: alpine_apk/update_output
   :caption: 更新alpine linux的软件包列表

- 然后可以更新系统:

.. literalinclude:: alpine_apk/upgrade
   :caption: 更新alpine linux系统

也可以结合上述两个命令成一个命令:

.. literalinclude:: alpine_apk/update_upgrade
   :caption: 一条命令完整更新alpine linux系统

- 如果只更新指定软件(例如busybox)，则使用:

.. literalinclude:: alpine_apk/upgrade_busybox
   :caption: 指定更新软件(例如busybox)

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

.. _alpine_apk_add:

apk添加软件包
===============

使用 ``add`` 可以从软件仓库安装一个软件包，所有依赖的软件包也会同时安装。如果有多个仓库，则 ``add`` 命令会安装最新的 软件包::

   apk add openssh
   apk add openssh openntp vim

默认只使用 ``main`` 仓库，软件是非常核心的，通常会同时激活 ``community`` 仓库，见上文。

如果只是想从 ``edge/testing`` 仓库安装一个软件包，但是不修改软件仓库配置，可以使用如下命令::

   apk add cfssl --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

这里仓库名见上文repo配置。这里案例是 :ref:`alpine_cfssl`

apk搜索软件包
==============

- 直接搜索软件包::

   apk search htop

- 搜素并显示描述::

   apk search -v -d 'htop'

- 列出所有软件包并且包含描述::

   apk search -v

- 搜索也可以使用匹配方法::

   apk search -v 'php7*'

固定软件版本不升级
====================

有时候需要保持某个软件包版本不随着系统升级而变化，可以使用类似::

   apk add bash=5.0.0-r0

也可以使用一个主板本来hold::

   apk add bash=~5.0

如果要解除版本锁定，则改为 ``>`` ::

   apk add bash>5.0.0-r0

安装本地下载的软件包
========================

- 可以安装本地软件包类似如下::

   apk add --allow-untrusted /path/to/foo.apk
   apk add --allow-untrusted pkg1.apk pkg2.apk

删除软件包
=============

- 以下命令删除软件包::

   apk del pkgName
   apk del pkgName1 pkgName2

查找某个文件属于哪个软件包
=============================

- 可以按照以下命令找出哪个软件包提供某个文件::

   apk info --who-owns /sbin/apk

基础软件安装
==================

- 默认最小化安装对于维护不是很方便，所以安装以下软件::

   # NFS客户端和服务
   apk add nfs-utils
   # 磁盘维护
   apk add lsblk cfdisk e2fsprogs
   # lspci等维护工具
   apk add pciutils
   # 下载工具
   apk add curl axel


参考
========

- `Alpine Linux package management <https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management>`_
- `How to add a edge/testing package to Alpine Linux? <https://stackoverflow.com/questions/62218240/how-to-add-a-edge-testing-package-to-alpine-linux>`_
