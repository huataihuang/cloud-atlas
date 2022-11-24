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
