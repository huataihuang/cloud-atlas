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

.. note::

   我这里有一个乌龙，我忘记执行 ``mkfs.xfs`` 格式化XFS文件系统，而直接使用了上述 ``lklfuse`` 来挂载一个EXT4文件系统作为XFS来挂载。结果导致该挂载目录hang死了，连 ``df`` 都出不来

参考
======

- `xfsprogs Utilities for managing XFS filesystems <https://www.freshports.org/filesystems/xfsprogs/>`_
- `XFS support <https://forums.freebsd.org/threads/xfs-support.61449/>`_
- `Where can I find the status of XFS for FreeBSD <https://forums.freebsd.org/threads/where-can-i-find-the-status-of-xfs-for-freebsd.82600/>`_
