.. _shrink_ext4_fs:

=============================
收缩EXT4文件系统
=============================

.. warning::

   磁盘分区收缩是高风险操作，非必要不要执行

   虽然我的实践是成功的，但是对于 :ref:`raspberry_pi_os` 我还是采用 :ref:`disable_auto_resize` ，然后采用手工 :ref:`expend_ext4_rootfs_online` 实现指定容量扩展。这样扩展分区指定大小后无需计算文件系统扩展的大小，并且EXT4文件系统扩展比收缩难度和风险要低，更安全一些。

我在 :ref:`pi_quick_start` 实践中发现，当 :ref:`raspberry_pi_os` 首次启动时，会自动将原本 ``dd`` 创建的启动盘的小分区自动扩展到占用整个磁盘。这在使用SD/TF卡的时候没有什么影响，因为原本SD/TF卡空间就很小，扩展占用整个SD/TF卡正好也满足需求。

但是，我在构建 :ref:`usb_boot_ubuntu_pi_4` 方案时，是希望将磁盘的大部分空间用于独立的存储服务，例如构建 :ref:`zfs` 或者分布式存储 :ref:`ceph` ，此时我需要收缩默认占用整个磁盘空间的EXT4文件系统。

.. note::

   EXT4文件系统只支持 :ref:`expend_ext4_rootfs_online` ，但是不能在线收缩。所以本文采用的是离线方式，也就是 ``umount`` 状态下收缩EXT4文件系统。

原理
======

- 在离线状态(umount)时，使用 ``resize2fs`` 命令可以收缩EXT4文件系统
- 收缩完EXT4文件系统后，再使用 ``fdisk`` 将分区改小(分区结束位置前移)

实践操作
=============

- :ref:`pi_quick_start` 之后，磁盘分区如下(根分区 ``/dev/sda2`` 已经扩展到整个磁盘):

.. literalinclude:: shrink_ext4_fs/partition_before
   :caption: ``/dev/sda2`` 分区已扩展到整个磁盘，待收缩

- 执行 ``fsck`` :

.. literalinclude:: shrink_ext4_fs/e2fsck
   :caption: 对 ``/dev/sda2`` 分区执行 fsck

.. literalinclude:: shrink_ext4_fs/e2fsck_output
   :caption: 对 ``/dev/sda2`` 分区执行 fsck 的输出信息

- 收缩分区到128G空间:

.. literalinclude:: shrink_ext4_fs/resize2fs
   :caption: 执行 ``resize2fs`` 收缩EXT4文件系统

.. literalinclude:: shrink_ext4_fs/resize2fs_output
   :caption: 执行 ``resize2fs`` 收缩EXT4文件系统时输出信息
   :emphasize-lines: 3

- 按照上述文件系统收缩以后，就可以使用fdisk调整分区大小来匹配已经收缩的文件系统:

.. literalinclude:: shrink_ext4_fs/fdisk_before
   :caption: 收缩前分区
   :emphasize-lines: 1,8,19

执行以下操作交互命令(高亮)，注意实际输入只有交互中的单个操作命令字符，例如 ``n`` 表示添加分区， ``p`` 表示打印分区:

.. literalinclude:: shrink_ext4_fs/fdisk_shrink
   :caption: 收缩分区操作
   :emphasize-lines: 1,2,6,18,22-24,25,30,34,49

.. note::

   这里输入分区的起始扇区是 ``1056768`` ，这个值和调整扇区之前的 ``/dev/sda2`` 分区起始位置一致(这样可以避免错位)

   输入分区的终止扇区值是 ``+268435456`` ，这个值实际上是之前 ``resize2fs`` 结果值 ``33554432`` 乘以 ``8`` : 因为 ``resize2fs`` 输出结果的值是以 ``4k`` 为单位，而 ``fdisk`` 操作命令的扇区 ``sector`` 是 ``512字节`` 。 

- 如果一切没有出错的话，将调整(shrink)分区挂载进行检查

.. literalinclude:: shrink_ext4_fs/mount
   :caption: 挂载 ``/dev/sda2`` 分区进行检查

此时我遇到一个报错:

.. literalinclude:: shrink_ext4_fs/mount_error
   :caption: 挂载 ``/dev/sda2`` 分区报错

怎么办？

- 执行一次 ``e2fsck`` 对 ``/dev/sda2`` 进行修复:

.. literalinclude:: shrink_ext4_fs/e2fsck
   :caption: 对 ``/dev/sda2`` 分区执行 fsck

此时会提示大量的 ``块位图不一致`` ( ``Block bitmap differences`` )，则按照提示进行 ``fix`` 修复

.. literalinclude:: shrink_ext4_fs/block_bitmap_differences
   :caption: fsck检查 ``/dev/sda2`` 分区可以看到大量的 ``Block bitmap differences`` ，按提示修复
   :emphasize-lines: 9,11

修复完成后，再次执行磁盘挂载就能够成功。

参考
=======

- `How to Shrink an ext2/3/4 File system with resize2fs <https://access.redhat.com/articles/1196333>`_
