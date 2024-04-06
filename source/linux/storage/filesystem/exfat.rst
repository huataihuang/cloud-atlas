.. _exfat:

================
ExFAT文件系统
================

有时候我需要在不同操作系统间通过U盘或移动硬盘交换文件，此时U盘/移动硬盘的文件系统选择就需要考虑跨平台以及是否支持大文件，长文件名等。我最初选择的是 ``VFST/FAT32`` ，但是发现现代系统中，超过4GB的文件比比皆是，会导致兼容性问题。

ExFAT优势
==========

``ExFAT`` 文件系统是目前跨操作系统兼容的选择:

- macOS支持ExFAT文件系统，Linux内核早期铜鼓FUSE支持，而内核5.7之后原生支持，所以使用非常方便
- 超越 ``FAT32/VFAT`` ，已经 **没有单个文件4G限制** ，这对现代的大文件交换非常有利

Gentoo使用ExFAT
=================

- 内核5.7及以上，可以直接安装 ``sys-fs/exfatprogs`` 软件包，包含了维护工具:

.. literalinclude:: exfat/gentoo_install_exfatprogs
   :caption: 在 :ref:`gentoo_linux` 上安装 ``sys-fs/exfatprogs``

文件复制
============

tar
-----

当采用 ``tar`` 结合管道来同步数据，我通常使用:

.. literalinclude:: ../zfs/admin/zfs_nfs/copy_docs
   :caption: 使用 ``tar`` 结合管道复制文件

但是 ``ExFAT`` 文件系统不支持 ``uid/gid`` 这样的属主属性，此时会大量报错:

.. literalinclude:: exfat/tar_ownership_err
   :caption: ``ExFAT`` 文件系统不支持 ``uid/gid`` 这样的属主属性

解决的方法是在使用 ``tar`` 归档时将 ``owner`` 和 ``group`` 都设置成 ``0`` ，并且使用 ``--no-same-owner --no-same-permissions`` 参数

.. literalinclude:: exfat/copy_docs
   :caption: ``tar`` 命令归档时忽略文件属主

参考
======

- `tar without preserving user [duplicate] <https://unix.stackexchange.com/questions/285237/tar-without-preserving-user>`_
- `File system formats available in Disk Utility on Mac <https://support.apple.com/guide/disk-utility/file-system-formats-dsku19ed921c/mac>`_
