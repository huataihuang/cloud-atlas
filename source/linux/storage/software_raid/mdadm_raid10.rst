.. _mdadm_raid10:

=====================
mdadm构建RAID10
=====================

在 :ref:`deploy_centos7_gluster11_lvm_mdadm_raid10` ，为了构建统一的大规格磁盘，采用 :ref:`linux_software_raid` 实现磁盘统一管理:

磁盘准备
===========

对于已经使用过的磁盘，需要清理磁盘分区和文件系统:

- 参考 :ref:`lvm_device_excluded_by_filter` 经验，对于已经使用过的旧磁盘(已经有分区信息或文件系统)，先抹除掉磁盘上信息:

.. literalinclude:: mdadm_raid10/wipefs_nvme
   :caption: 使用 ``wipefs`` 擦除磁盘上分区和文件系统

.. literalinclude:: mdadm_raid10/wipefs_12_nvme
   :language: bash
   :caption: 简单脚本(类似 :ref:`centos_gluster_init` )，将服务器上12块 :ref:`nvme` 磁盘初始化

.. note::

   构建 ``mdadm`` 软RAID建议采用分区，见 :ref:`mdadm_partion_vs_disk`

- 分区构建:

.. literalinclude:: mdadm_raid10/raid_part
   :language: bash
   :caption: 创建分区并设置为RAID

以上命令我实际上合并成一个组合脚本来完成:

.. literalinclude:: mdadm_raid10/init_disk_for_mdadm
   :caption: 为 ``mdadm`` 准备磁盘分区脚本

.. warning::

   如果之前已经在 ``/etc/fstab`` 中配置过磁盘目录挂载，则一定要先删除 ``/etc/fstab`` 中不需要的文件系统挂载配置，然后执行一次:

   .. literalinclude:: ../../redhat_linux/systemd/systemd_mount/systemctl_daemon-reload
      :caption: 执行 ``daemon-reload`` 刷新

   这样才能确保 :ref:`systemd_fstab_generator` 自动生成的 ``.mount`` unit 配置正确刷新，不会因为 :ref:`systemd_mount` 反复自动挂载之前的文件系统

创建RAID10
===============

- 执行创建RAID10( **注意使用分区** ):

.. literalinclude:: mdadm_raid10/mdadm_create_raid10
   :language: bash
   :caption: 创建RAID10

.. note::

   这里我闹过一个乌龙，忘记加上分区，正确应该是 ``/dev/nvme{0..11}n1p1`` 表示 :ref:`nvme` 设备的第一个分区，我错写成 ``/dev/nvme{0..11}n1`` 实际上就是直接对整个磁盘进行创建RAID，此时会提示告警::

      mdadm: /dev/nvme0n1 appears to be part of a raid array:
             level=raid0 devices=0 ctime=Thu Jan  1 08:00:00 1970
      mdadm: partition table exists on /dev/nvme0n1 but will be lost or
             meaningless after creating array 
      ...

   则 :ref:`mdadm_remove_md` 后再重新开始

如果正确，则提示信息:

.. literalinclude:: mdadm_raid10/mdadm_create_raid10_output
   :language: bash
   :caption: 创建RAID10

- 检查状态:

.. literalinclude:: mdadm_raid10/mdstat
   :caption: 检查md状态

输出状态类似:

.. literalinclude:: mdadm_raid10/mdstat_output
   :caption: 检查md状态可以看到RAID正在构建

.. note::

   这里看到的 ``chunk`` 是 ``65536KB chunk`` ，让我有些疑惑，为何会这么巨大，是否有更好的优化? 看起来I/O可能会比较集中在个别磁盘，而不是非常均匀分布到所有磁盘；优点是...

- 使用 ``--detail`` 指令可以检查详情:

.. literalinclude:: mdadm_raid10/mdadm_detail
   :caption: 使用 ``mdadm --detail`` 检查RAID详情

可以看到详细状态如下:

.. literalinclude:: mdadm_raid10/mdadm_detail_output
   :caption: 使用 ``mdadm --detail`` 检查RAID详情输出

下一步
=======

在 :ref:`deploy_centos7_gluster11_lvm_mdadm_raid10` 方案中， :ref:`deploy_lvm_mdadm_raid10` 作为中间逻辑卷数据管理
 
参考
======

- `Red Hat Enterprise Linux 9 Docs > Managing storage devices > Chapter 18. Managing RAID <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/managing_storage_devices/managing-raid_managing-storage-devices>`_
- `Red Hat Enterprise Linux 9 Docs > 管理存储设备 > 第18章 管理RAID <https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/9/html/managing_storage_devices/managing-raid_managing-storage-devices>`_ (中文版)
- `How to configure RAID6 in centos 7 <https://www.linuxhelp.com/how-to-configure-raid6-in-centos-7>`_
- `Create Software RAID 10 With mdadm <https://allcloud.io/blog/create-software-raid-10-with-mdadm/>`_
- `SUSE Linux Enterprise Server Documentation / Storage Administration Guide / Software RAID / Creating Software RAID 10 Devices <https://documentation.suse.com/sles/15-SP1/html/SLES-all/cha-raid10.html>`_
