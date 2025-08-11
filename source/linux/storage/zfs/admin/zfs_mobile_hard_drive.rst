.. _zfs_mobile_hard_drive:

==============================
移动硬盘ZFS
==============================

之前移动硬盘使用了 macOS 的 HFS+ 系统，准备转换成ZFS系统，方便跨 Linux/FreeBSD/macOS 使用

- 检查分区:

.. literalinclude:: zfs_mobile_hard_drive/gpart_show
   :caption: 检查磁盘分区

输出显示:

.. literalinclude:: zfs_mobile_hard_drive/gpart_show_output
   :caption: 检查磁盘分区看到 ``diskid/DISK-57584831414135434E4C3531``
   :emphasize-lines: 8

- 参考 :ref:`freebsd_zfs_stripe` 构建条带化ZFS:

.. literalinclude:: zfs_mobile_hard_drive/zpool
   :caption: 创建 ``zstore`` 存储池

启用 ``zstd`` 压缩，参考 :ref:`zfs_compression` 对两种压缩方式的对比

数据备份同步: :ref:`zfs_replication`
