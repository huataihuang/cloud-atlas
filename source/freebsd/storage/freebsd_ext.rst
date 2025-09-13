.. _freebsd_ext:

==============================
FreeBSD使用Linux EXT文件系统
==============================

.. warning::

   FreeBSD主要使用原生UFS(Unix File System)和 :ref:`zfs` 文件系统，以获得高级、稳定和可靠的特性。

   FreeBSD对其他操作系统对文件系统支持有限，有些是内核直接支持(如Linux EXT)，有些则需要用户空间工具(FUSE)支持(例如 :ref:`freebsd_ext4` 和 :ref:`freebsd_xfs` )。所以，对第三方操作系统的文件系统使用需要非常谨慎。

参考
========

- `FreeBSD handbook: 23.2. Linux File Systems <https://docs.freebsd.org/en/books/handbook/filesystems/#filesystems-linux>`_
