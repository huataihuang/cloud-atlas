.. _btrfs_mobile_cloud:

=========================
移动云计算的Btrfs实践
=========================

由于 :ref:`asahi_linux` 的内核迭代非常激进，最新的 v6.1 内核已经超出了 ``OpenZFS`` 支持的最高 v6.0版本，所以在 :ref:`archlinux_zfs-dkms` 遇到困难。为了能够在 :ref:`mobile_cloud_infra` 中实践前沿Linux技术，考虑到 ``Btrfs`` 是Linux内核主线内置支持，我于2022年11月，改为采用 ``Btrfs`` 来构建 :ref:`docker_btrfs_driver` 。

前置工作 
==========

- 安装 ``btrfs-progs`` 工具:

.. literalinclude:: btrfs_mobile_cloud/pacman_btrfs-progs
   :language: bash
   :caption: arch linux安装btrfs工具并加载内核模块

磁盘分区
============

由于在 :ref:`apple_silicon_m1_pro` 的MacBook Pro 2022，我放弃了之前的 :ref:`archlinux_zfs-dkms` ，但是分区方式沿用，所以依然使用 :ref:`parted` 对磁盘进行分区，做了一些细微调整:

.. csv-table:: 移动云计算的磁盘分区
   :file: btrfs_mobile_cloud/mobile_cloud_parted.csv
   :widths: 20,20,30,30
   :header-rows: 1

- 划分分区:

.. literalinclude:: btrfs_mobile_cloud/parted_nvme_btrfs
   :language: bash
   :caption: parted分区: 50G data, 48G docker, 216G libvirt

- 完成后检查 ``parted /dev/nvme0n1 print`` 输出信息如下:

.. literalinclude:: btrfs_mobile_cloud/parted_nvme_print
   :language: bash
   :caption: parted分区输出
   :emphasize-lines: 13-15

.. note::

   分区删除然后重建可能需要重启系统才能正确感知分区，我尝试 ``partx -a /dev/nvme0n1`` 和 ``partprobe`` 都没有成功

btrfs文件系统
==================

- 对分区 7/8 进行文件系统格式化，并挂载(启用 ``lzo`` 压缩):

.. literalinclude:: btrfs_mobile_cloud/mkfs.btrfs
   :language: bash
   :caption: 对分区 7/8 进行文件系统格式化，并挂载

使用btrfs
==================

- :ref:`docker_btrfs_driver`
- :ref:`btrfs_nfs` 为 :ref:`kind` 构建共享存储
