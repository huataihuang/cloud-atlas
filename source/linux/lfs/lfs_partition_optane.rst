.. _lfs_partition_optane:

=====================================
LFS分区( :ref:`intel_optane_m10` )
=====================================

我在二手 :ref:`hpe_dl360_gen9` 构建 ``x86_64`` 模拟集群，需要保障底层物理服务器稳定。其中，OS的磁盘可靠性是非常关键的因素。

我考虑的技术方案是:

- 采用 :ref:`zfs` RAIDZ 构建OS存储( :ref:`archlinux_root_on_zfs` )，通过软件RAID方式来确保数据冗余和高可用
- 采用 :ref:`intel_optane_m10` 这种超级可靠硬件来构建基础OS存储(我通过淘宝购买了一块16G规格傲腾M10，只需要13块RMB)

较为简单粗暴的方案是使用稳定可靠的 :ref:`intel_optane_m10` ，也就是目前我采用的实用方案: 用简单便宜但更为可靠的硬件来提升系统稳定性。不过，出于性价比(廉价)原因，我使用的16G规格 :ref:`intel_optane_m10` 实际容量是 ``13.41GiB`` :

.. literalinclude:: ../storage/nvme/intel_optane_m10/fdisk_optane_before
   :caption: :ref:`intel_optane_m10` 实际容量是 ``13.41GiB``

分区
=======

:ref:`lfs_partitions` 步骤可以按照需要氛围多个常用分区，也可以简化为2个分区:

.. literalinclude:: lfs_partition_optane/parted
   :caption: 对 :ref:`intel_optane_m10` 分区准备LFS部署

完成后执行 ``parted /dev/nvme0n1 print`` 输入如下:

.. literalinclude:: lfs_partition_optane/parted_output
   :caption: 对 :ref:`intel_optane_m10` 分区后检查输出
   :emphasize-lines: 8,9

设置环境变量
=================

- 在 ``/etc/profile`` 中配置:

.. literalinclude:: lfs_prepare/env
   :caption: ``/etc/profile`` 中添加LFS环境变量

挂载分区
============

- 创建 ``/mnt/lfs`` 目录，并挂载分区

.. literalinclude:: lfs_partition_optane/mount
   :caption: 挂载分区

- 由于 :ref:`intel_optane_m10` 空间很小，所以我将 ``存储BLFS源代码`` 独立到一个单独的硬盘分区挂载到 ``/usr/src`` 目录

.. literalinclude:: lfs_partition_optane/mount_src
   :caption: 单独为LFS提供一个源代码编译挂载目录 ``/usr/src``

- 完成后使用 ``df -h`` 检查

.. literalinclude:: lfs_partition_optane/mount_output
   :caption: 挂载分区,其中2个分区LFS安装，第3个分区是LFS源代码存储
   :emphasize-lines: 3,4

准备工作已经完成，现在可以开始准备软件包了

下一步
========

接下来的步骤是通用步骤，从 :ref:`lfs_prepare` 的 :ref:`lfs_wget` 开始继续
