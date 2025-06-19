.. _freebsd_apfs:

======================
FreeBSD APFS
======================

我有一个移动硬盘以前是在 :ref:`macos` 上使用的，所以格式化成 :ref:`apfs` 。现在我的服务器转为FreeBSD之后，需要有一个方法能够在FreeBSD中读取这个磁盘。

插入移动硬盘之后，观察到如下磁盘分区( ``gpart show`` ):

.. note::

   待实践，目前我的旧硬盘使用了 HFS+ ，所以暂时实践  :ref:`freebsd_hfs` 。后续待有机会再实践apfs

简单来说，需要安装  ``devel/libfsapfs`` 来获得 ``fsapfsmount`` 工具:

.. literalinclude:: freebsd_apfs/install_fsapfsmount
   :caption: 安装 ``devel/libfsapfs`` 来获得 ``fsapfsmount`` 工具

执行以下命令挂载:

.. literalinclude:: freebsd_apfs/mount_apfs
   :caption: 挂载APFS分区

参考
======

- `fsapfsmount -- mounts an	Apple File System (APFS) container <https://man.freebsd.org/cgi/man.cgi?query=fsapfsmount>`_
- `Mounting APFS partition <https://forums.freebsd.org/threads/mounting-apfs-partition.69094/>`_
