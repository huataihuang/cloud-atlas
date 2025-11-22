.. _freebsd_xfs:

==============================
FreeBSD使用Linux XFS文件系统
==============================

``xfsprogs``
===============

第三方在FreeBSD上移植了 `xfsprogs Utilities for managing XFS filesystems <https://www.freshports.org/filesystems/xfsprogs/>`_

- 安装 ``xfsprogs`` :

.. literalinclude:: freebsd_xfs/install_xfsprogs
   :caption: 安装 ``xfsprogs``

- 格式化XFS文件系统:

.. literalinclude:: freebsd_xfs/mkfs.xfs
   :caption: 格式化XFS文件系统

输出信息:

.. literalinclude:: freebsd_xfs/mkfs.xfs_output
   :caption: 格式化XFS文件系统

挂载XFS
==========

很不幸，FreeBSD内核已经移除了XFS支持，所以不能直接挂载，需要通过 FUSE 来实现XFS挂载

- 安装 ``fusefs-lkl`` :

.. literalinclude:: freebsd_xfs/install_fusefs-lkl
   :caption: 安装 ``fusefs-lkl``

- 加载 ``fusefs`` 内核模块

.. literalinclude:: freebsd_xfs/kldload_fusefs
   :caption: 加载 ``fusefs`` 内核模块

- 挂载磁盘分区:

.. literalinclude:: freebsd_xfs/fuse_mount
   :caption: 使用 ``lklfuse`` 挂载XFS文件系统

需要注意:

- 由于是 ``fuse`` 方式挂载目录，所以需要指定 ``uid,gid`` ，例如这里指定 ``admin`` 用户的 ``uid`` (501) 和 ``gid`` (501)，这样所有存放到该目录下的用户的属主都会自动映射为 ``admin`` 用户属主，就能以该用户来访问该目录读写
- 这里通过 ``root`` 用户执行挂载命令时，由于是将目录指定给 ``admin`` 用户使用，必须使用 ``allow_other`` 参数，否则即使挂载后该 ``/lfs`` 目录属主是 ``admin`` 用户，该 ``admin`` 用户也无法进入目录，会提示错误 **cd: /lfs: Operation not permitted**

但是如果以 ``admin`` 用户去执行 ``lklfuse`` 命令来挂载磁盘分区，会提示对磁盘分区没有操作权限::

   /dev/diskid/DISK-Y39B70RTK7ASp6: Permission denied

检查 ``/dev/diskid/DISK-Y39B70RTK7ASp6`` 设备的属主是 ``root operator`` ，我尝试将 ``admin`` 用户假如到 ``operator`` 组，但是发现仅仅绕过了 ``/dev/diskid/DISK-Y39B70RTK7ASp6`` 权限限制，但是依然无法将 ``/dev/fuse`` 设备绑定 ``/lfs`` 目录::

   $ mount_fusefs: /dev/fuse on /lfs: Operation not permitted

最终验证发现，采用 ``root`` 身份来挂载，在使用了 ``uid=501,gid=501`` 同时配套使用 ``allow_other`` 选项，就能够正确挂载目录，并且让 ``admin`` 用户访问和读写

.. note::

   我这里有一个乌龙，我忘记执行 ``mkfs.xfs`` 格式化XFS文件系统，而直接使用了上述 ``lklfuse`` 来挂载一个EXT4文件系统作为XFS来挂载。结果导致该挂载目录hang死了，连 ``df`` 都出不来

- 配置 :strike:`/etc/fstab` **没有找到如何在/etc/fstab中配置xfs以fuse方式挂载的方法**

下一步
========

我的目标是 

- XFS挂载目录提供给 :ref:`linux_jail_rocky-base` ，就能够在Linux容器内部来构建新的LFS系统

参考
======

- `xfsprogs Utilities for managing XFS filesystems <https://www.freshports.org/filesystems/xfsprogs/>`_
- `XFS support <https://forums.freebsd.org/threads/xfs-support.61449/>`_
- `Where can I find the status of XFS for FreeBSD <https://forums.freebsd.org/threads/where-can-i-find-the-status-of-xfs-for-freebsd.82600/>`_
