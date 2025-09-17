.. _freebsd_ext4:

================================
FreeBSD使用Linux EXT4文件系统
================================

``e2fsprogs``
===============

非官方支持的修订版本 ``e2fsprogs`` 软件包，提供了 ``mkfs.ext2  mkfs.ext3  mkfs.ext4`` 系列工具来创建EXT文件系统:

.. literalinclude:: freebsd_ext/install_e2fsprogs-core
   :caption: 安装 ``e2fsprogs-core`` 来支持EXT文件系统创建

然后就可以对磁盘分区进行EXT4文件系统创建:

.. literalinclude:: freebsd_ext4/mkfs.ext4
   :caption: 创建ext4文件系统

输出信息(因为之前已经创建过ext4文件系统):

.. literalinclude:: freebsd_ext4/mkfs.ext4_output
   :caption: 创建ext4文件系统

- 使用FreeBSD提供的 ``ext2fs`` 内核模块来挂载 ``ext2, ext3, ext4`` 文件系统:

.. literalinclude:: freebsd_ext/mount
   :caption: 使用 ``ext2fs`` 驱动挂载EXT文件系统

参考
======

- `newfs for ext2/3/4 <https://forums.freebsd.org/threads/newfs-for-ext2-3-4.60325/>`_
