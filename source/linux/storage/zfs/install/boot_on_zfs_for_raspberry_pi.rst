.. _boot_on_zfs_for_raspberry_pi:

==============================
树莓派Root on ZFS
==============================

目标
======

在 :ref:`pi_soft_storage_cluster` 实践，我想要构建一个模拟生产环境服务器部署的高可用存储:

- 整个Linux系统运行在ZFS之上，通过 ``RAIDZ`` 确保任何一块磁盘故障不会导致整个服务器瘫痪
- 没有钱(失业了)购买足够的 :ref:`nvme` 存储来真实模拟，所以采用在一块 :ref:`kioxia_exceria_g2` 通过磁盘分区(块设备)来模拟多磁盘

  - 考虑到操作系统实际上只要保证冗余即可(还没有达到需要通过RAIDZ的海量磁盘来构建)，所以我会用两个分区来模拟两块磁盘部署
  - 为了模拟磁盘故障和恢复，在完成部署后，将采用 ``dd`` 命令抹除其中一个系统磁盘数据(破坏部分)，然后实践如何恢复ZFS RAID1

- 使用 **一台** :ref:`pi_5` 模拟生产环境 :ref:`arm` 架构服务器

- (进一步)尝试构建ZFS RAIDZ (3个磁盘分区) 存储来模拟更多的ZFS管理

参考
=======

- `OpenZFS文档: Ubuntu 22.04 Root on ZFS for Raspberry Pi <https://openzfs.github.io/openzfs-docs/Getting%20Started/Ubuntu/Ubuntu%2022.04%20Root%20on%20ZFS%20for%20Raspberry%20Pi.html>`_
