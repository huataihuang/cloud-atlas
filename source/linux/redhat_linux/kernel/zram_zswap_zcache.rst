.. _zram_zswap_zcache:

===========================================
``zram`` vs ``zswap`` vs ``zcache``
===========================================

在 Ask Ubuntu 有一个辨析 ``zram`` vs ``zswap`` vs ``zcache`` 的文章: `zram vs zswap vs zcache Ultimate guide: when to use which one <https://askubuntu.com/questions/471912/zram-vs-zswap-vs-zcache-ultimate-guide-when-to-use-which-one>`_ :

概述
============

- :ref:`zram` : 不需要在磁盘设备(HDD/SDD)上有交换设备，直接在内存中构建压缩块设备提供内存页交换功能，纯粹是增大内存使用率
- :ref:`zswap` : 需要结合磁盘设备(HDD/SDD)的交换设备文件，通过拦截交换到磁盘的内存页进行内存池压缩来加速内存换页性能
- zcache: 针对文件系统页缓存的加速，用以提高文件系统性能
