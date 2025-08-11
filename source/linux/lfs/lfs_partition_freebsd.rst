.. _lfs_partition_freebsd:

================================
LFS分区(和FreeBSD一起Dualboot)
================================

我组装 :ref:`nasse_c246` 的电脑，部署了 :ref:`freebsd` 系统来构建 :ref:`freebsd_machine_learning` 。但是，实践中遇到了一些挫折:

原本想 :ref:`bhyve_nvidia_gpu_passthru` ，但是NVIDIA显卡在 :ref:`bhyve` 中PCI passthru无法完成，这阻碍了我进一步的 :ref:`machine_learning` 学习。由于我购买了2块 :ref:`amd_radeon_instinct_mi50` ，所以准备继续尝试 :ref:`bhyve_amd_gpu_passthru` 。

不过， :ref:`nvidia_gpu` 是目前 :ref:`machine_learning` 的主流硬件，我需要充分发挥所以的硬件来构建实验环境。所以，我考虑同时安装 :ref:`lfs` ，构建一个 Dualboot 环境:

- 在 FreeBSD 和 Linux 之间无缝切换:

  - 所有的存储方案( :ref:`ceph` / :ref:`zfs` )在两个OS系统中都实现，任何时候切换都不影响整个homelab的运行
  - 存储数据共享: Linux和FreeBSD都能访问相同一份数据，节约资源

- FreeBSD和LFS仅仅是底座，不影响上层的虚拟化:

  - 切换到任意FreeBSD或LFS，都能启动存储在 :ref:`zfs` 中的虚拟化，甚至 :ref:`docker` 容器(可行么? jail 和 docker 能共享兼容么?)
  - 原先计划构建的基础服务，我准备在两个系统中都 ``1:1`` 复制构建，来验证我的底层系统无关的构想

磁盘
=========

- 首先使用 :ref:`gpart` 工具检查(因为已经安装好了 :ref:`freebsd` ，使用 :ref:`zfs` 作为根文件系统):

.. literalinclude:: lfs_partition_freebsd/gpart
   :caption: 使用 gpart 检查磁盘分区

输出显示:

.. literalinclude:: lfs_partition_freebsd/gpart_output
   :caption: 使用 gpart 检查磁盘分区
   :emphasize-lines: 8,12

注意:

  - ``efi`` 分区将是 FreeBSD 和 Linux 共用的FAT32分区
  - ``1.6T`` 的分区4 (freebsd-zfs) 是之前 :ref:`freebsd_zfs_stripe` 中的一个分区，该分区上的 ``zdata`` zpool我已经销毁，所以这个分区将删除重建，分别用于 :ref:`lfs` 以及重新构建一个 :ref:`freebsd_zfs_stripe` ``zdata``
  - ``diskid/DISK-54UA4072K7AS`` 也是 :ref:`freebsd_zfs_stripe` 构建的分区，后续将清理掉重新构建 :ref:`freebsd_zfs_stripe` ``zdata``

- ``diskid/DISK-Y39B70RTK7AS`` 删除分区(系统磁盘):

.. literalinclude:: lfs_partition_freebsd/delete_partition
   :caption: 删除分区

删除系统磁盘的第 4 分区

- ``diskid/DISK-54UA4072K7AS`` 删除分区(数据磁盘):

.. literalinclude:: lfs_partition_freebsd/delete_partition_data
   :caption: 删除数据磁盘分区

- 现在磁盘不需要的分区已经删除，检查:

.. literalinclude:: lfs_partition_freebsd/gpart
   :caption: 使用 gpart 再次检查磁盘分区

显示空闲空间:

.. literalinclude:: lfs_partition_freebsd/gpart_partition_free
   :caption: 使用 gpart 再次检查磁盘分区，可以看到空白部分
   :emphasize-lines: 2,9

- 在系统盘上创建一个 ``linux-data`` 类型的Linux分区256G，并将该系统盘剩余空间创建为zfs分区

.. literalinclude:: lfs_partition_freebsd/gpart_add_partition
   :caption: 使用 gpart 创建一个 ``linux-data`` 和 ``freebsd-zfs`` 分区

另一个数据磁盘则完整划分一个ZFS分区

.. literalinclude:: lfs_partition_freebsd/gpart_add_partition_zfs
   :caption: 使用 gpart 将数据盘完整划分为一个ZFS分区

- 最终完成的分区:

.. literalinclude:: lfs_partition_freebsd/gpart
   :caption: 使用 gpart 检查磁盘分区

显示如下:

.. literalinclude:: lfs_partition_freebsd/gpart_finish
   :caption: 使用 gpart 检查最终的分股情况
   :emphasize-lines: 3,11,12

构建ZFS
==========

上述2个NVMe磁盘的 ``1.3T`` 和 ``1.8T`` 分区，采用 :ref:`freebsd_zfs_stripe` 方式再次重建 ``zdata`` :

.. literalinclude:: lfs_partition_freebsd/zfs_stripe
   :caption: 创建 ``stripe`` 模式的 ``zdata``

- 检查zpool:

.. literalinclude:: lfs_partition_freebsd/zpool_list
   :caption: 检查zpool

输出可以看到 ``zdata`` 跨了2块磁盘:

.. literalinclude:: lfs_partition_freebsd/zpool_list_output
   :caption: zpool ``zdata`` 跨了2块磁盘
   :emphasize-lines: 3,4

构建ZFS的dataset
------------------

- 主要的ZFS dataset:

  - ``zdata/docs`` 日常操作数据(启用 ``zstd`` 压缩)
  - ``zdata/vms`` :ref:`bhyve` 虚拟机
  - ``zdata/jails`` :ref:`freebsdjail` 容器

我已经在 :ref:`zfs_replication` 中完成了备份，所以现在将上述 ``zdata/vms`` 和 ``zdata/jails`` 恢复回来:

.. literalinclude:: lfs_partition_freebsd/restore_zdata
   :caption: 恢复 ``zdata`` 上数据集
