.. _freebsd_ext:

==============================
FreeBSD使用Linux EXT文件系统
==============================

.. warning::

   FreeBSD主要使用原生UFS(Unix File System)和 :ref:`zfs` 文件系统，以获得高级、稳定和可靠的特性。

   FreeBSD对其他操作系统对文件系统支持有限，有些是内核直接支持(如Linux EXT)，有些则需要用户空间工具(FUSE)支持(例如 :ref:`freebsd_ext4` 和 :ref:`freebsd_xfs` )。所以，对第三方操作系统的文件系统使用需要非常谨慎。

FreeBSD在内核中集成了Linux EXT文件系统支持，但是需要注意:

- ``ext2fs`` 驱动允许FreeBSD内核直接读写 ext2, ext3 和 ext4 文件系统
- ``警告`` 警告: 不支持EXT文件系统的日志和加密功能，也即是说，如果发生断电，需要手工运行fsck来修复EXT文件系统，没有内置直接的日志恢复功能

- 这里前置步骤是完成 :ref:`bhyve_storage` ，我将 ``nda0`` 磁盘的分区4透传给 bhyve 虚拟机，利用 :ref:`ubuntu_linux` 虚拟机来完成 EXT4 文件系统创建

.. note::

   我最初以为FreeBSD不支持EXT文件系统的创建，所以特意实践了 :ref:`bhyve_storage` 来通过 :ref:`ubuntu_linux` 完成EXT4文件系统创建。

   不过，后来找到非官方支持的修订版本 ``e2fsprogs`` 软件包，提供了 ``mkfs.ext2  mkfs.ext3  mkfs.ext4`` 系列工具来创建EXT文件系统:

   .. literalinclude:: freebsd_ext/install_e2fsprogs-core
      :caption: 安装 ``e2fsprogs-core`` 来支持EXT文件系统创建

- 执行以下命令将已经创建好EXT4文件系统的 ``/dev/diskid/DISK-Y39B70RTK7ASp4`` 磁盘分区挂载:

.. literalinclude:: freebsd_ext/mount
   :caption: 使用 ``ext2fs`` 驱动挂载EXT文件系统

已验证读写没有问题

.. note::

   如果Host主机的物理磁盘分区 ``/dev/diskid/DISK-Y39B70RTK7ASp4`` 透传给虚拟机，并且虚拟机处于运行状态，则此时在Host主机上无法挂载分区，提示报错:

   .. literalinclude:: freebsd_ext/mount_not_permit
      :caption: 当Host主机物理磁盘分区被虚拟机透传使用时，Host主机无法挂载该分区

   当然，只要停止使用该分区的虚拟机之后，就可以完成Host主机挂载EXT分区了

参考
========

- `FreeBSD handbook: 23.2. Linux File Systems <https://docs.freebsd.org/en/books/handbook/filesystems/#filesystems-linux>`_
