.. _freebsd_disk:

===================
FreeBSD磁盘
===================

在阿里云的FreeBSD虚拟机添加了数据磁盘，但是发现和Linux平台有些不同，所以快速学习和实践一下:

磁盘
======

- 首先找出磁盘，因为我发现没有 ``fdisk -l`` 这样的Linux命令，那么替代命令是 ``geom`` (universal control utility for GEOM classes):

.. literalinclude:: freebsd_disk/geom_disk
   :caption: 使用 ``geom`` 列出磁盘

.. literalinclude:: freebsd_disk/geom_disk_output
   :caption: 使用 ``geom`` 列出磁盘
   :emphasize-lines: 13,16

这里可以看到我刚添加的虚拟磁盘 ``vtbd1`` (750G)

知道磁盘名字之后，就可以再添加磁盘名字来显示信息:

.. literalinclude:: freebsd_disk/geom_disk_vtbd1
   :caption: 检查 ``vtbd1`` 磁盘

分区
=======

.. note::

   这里按照传统方式，使用 UFS 文件系统，其实使用 :ref:`zfs` 更为简单。不过，这里为了练习

- ``gpart`` 命令可以创建分区，而且可以通过 ``-s`` 参数指定大小(如果没有指定大小则完全占用空闲空间)；然后可以创建文件系统:

.. literalinclude:: freebsd_disk/gpart
   :caption: 创建分区和文件系统

.. note::

   操作不难但也不很方便，感觉还是 :ref:`zfs` 使用更为简便

参考
======

- `FreeBSD List and Find Out All Installed Hard Disk Size Information <https://www.cyberciti.biz/faq/freebsd-hard-disk-information/>`_
- `How To Add A Second Hard Disk on FreeBSD <https://www.cyberciti.biz/faq/freebsd-adding-second-hard-disk-howto/>`_
