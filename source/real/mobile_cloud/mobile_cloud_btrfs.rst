.. _mobile_cloud_btrfs:

=========================
移动云Btrfs
=========================

在 :ref:`apple_silicon_m1_pro` 的MacBook Pro 2022笔记本上，安装 :ref:`asahi_linux` ，存储文件系统采用 :ref:`btrfs` (内核版本升级到6.1之后无法采用 :ref:`mobile_cloud_zfs` )

前置工作 
==========

- 安装 ``btrfs-progs`` 工具:

.. literalinclude:: ../../linux/storage/btrfs/btrfs_mobile_cloud/pacman_btrfs-progs
   :language: bash
   :caption: arch linux安装btrfs工具并加载内核模块

磁盘分区
=============

.. csv-table:: 移动云计算的磁盘分区
   :file: ../../linux/storage/btrfs/btrfs_mobile_cloud/mobile_cloud_parted.csv
   :widths: 20,20,30,30
   :header-rows: 1

- 划分分区:

.. literalinclude:: ../../linux/storage/btrfs/btrfs_mobile_cloud/parted_nvme_btrfs
   :language: bash
   :caption: parted分区: 50G data, 48G docker, 216G libvirt

- 完成后检查 ``parted /dev/nvme0n1 print`` 输出信息如下:

.. literalinclude:: ../../linux/storage/btrfs/btrfs_mobile_cloud/parted_nvme_print
   :language: bash
   :caption: parted分区输出
   :emphasize-lines: 13-15

.. note::

   分区7和8采用Btrfs，另外一个分区9保留给 :ref:`mobile_cloud_libvirt_lvm_pool`

btrfs文件系统
==================

- 对分区 7/8 进行文件系统格式化，并挂载(启用 ``lzo`` 压缩):

.. literalinclude:: ../../linux/storage/btrfs/btrfs_mobile_cloud/mkfs.btrfs
   :language: bash
   :caption: 对分区 7/8 进行文件系统格式化，并挂载

存储使用
==========

- 后续为 :ref:`mobile_cloud_k8s` 提供 :ref:`btrfs_nfs` 实现容器间共享存储

