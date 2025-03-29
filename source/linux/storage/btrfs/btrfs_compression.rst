.. _btrfs_compression:

===========================
Btrfs压缩
===========================

压缩率
========

我在 :ref:`btrfs_mobile_cloud` 启用了 Btrfs 的 ``lzo`` 透明压缩选项，挂载 ``/data`` 目录。这个目录下存放了日常数据，压缩效果究竟如何呢?

``Btrfs`` 工具没有提供直接观察方法，但是可以使用 ``compsize`` 工具统计

- 安装 ``compsize`` ::

   pacman -S compsize

- 直接观察挂载目录::

   compsize /data

输出信息类似::

   Processed 354744 files, 52375 regular extents (52375 refs), 310694 inline.
   Type       Perc     Disk Usage   Uncompressed Referenced  
   TOTAL       77%      3.7G         4.8G         4.8G       
   none       100%      3.0G         3.0G         3.0G       
   lzo         38%      715M         1.8G         1.8G

可以看到大约有 ``1.8G`` 数据被压缩到 ``715M`` ，即节约了1G的空间

参考
======

- `Btrfs Wiki: Compression <https://btrfs.wiki.kernel.org/index.php/Compression>`_
- `btrfs: how to calculate btrfs compression space savings? <https://unix.stackexchange.com/questions/389520/btrfs-how-to-calculate-btrfs-compression-space-savings>`_
