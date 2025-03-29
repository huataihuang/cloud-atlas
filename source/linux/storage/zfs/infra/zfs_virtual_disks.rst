.. _zfs_virtual_disks:

===============
ZFS虚拟磁盘
===============

我们在学习类似ZFS这样存储技术的时候，往往没有企业级的多磁盘物理服务器设备。但是，和虚拟化技术类似，我们并不需要购买昂贵的设备才能完成实践。Linux支持将文件作为 ``VDEV`` ，这样就可以用一台服务器来满足各种硬件虚拟磁盘条件，我们可以演练技术，并为生产部署做好准备。

.. note::

   本文实践在 :ref:`fedora` 虚拟机 ，也就是 :ref:`z-dev` 上完成

   注意: 使用文件作为 ``VDEV`` 不可用于存储 ``真实`` 数据，仅用于开发和测试

创建虚拟磁盘
=============

使用 ``truncate`` 工具创建文件:

.. literalinclude:: zfs_virtual_disks/truncate_vdev
   :language: bash
   :caption: 使用 ``truncate`` 构建3个2G大小的虚拟磁盘

``RAIDZ1``
===========

- 准备好 :ref:`fedora_zfs` 环境

``RAIDZ1`` 是一种类似RAID 5的存储技术，提供了 ``(n-1)/n`` 的可用容量

.. literalinclude:: zfs_virtual_disks/zpool_create
   :language: bash
   :caption: 创建名为 ``zpool-data`` 的 raidz类型 zfs存储池

这里我曾经使用过 `ZFS/Virtual disks <https://wiki.archlinux.org/title/ZFS/Virtual_disks>`_ 文档中指定类型 ``zraid1`` ::

   zpool create zpool-data zraid1 /vdisk/1.img /vdisk/2.img /vdisk/3.img

但是会报错::

   cannot open 'zraid1': no such device in /dev
   must be a full path or shorthand device name

所以还是改为 ``raidz`` 类型

- 检查zpool存储池:

.. literalinclude:: zfs_virtual_disks/zpool_list
   :language: bash
   :caption: 检查zpool存储池

输出显示:

.. literalinclude:: zfs_virtual_disks/zpool_list_output
   :language: bash
   :caption: 检查zpool存储池输出

- 检查zfs(包括挂载信息):

.. literalinclude:: zfs_virtual_disks/zfs_list
   :language: bash
   :caption: 检查zfs

输出显示:

.. literalinclude:: zfs_virtual_disks/zfs_list_output
   :language: bash
   :caption: 检查zfs信息输出

- 此时使用 ``df -h`` 名利ing检查，也可以看到目录已经挂载好::

   Filesystem      Size  Used Avail Use% Mounted on
   ...
   zpool-data      3.6G  128K  3.6G   1% /zpool-data

- 检查zpool状态:

.. literalinclude:: zfs_virtual_disks/zpool_satus
   :language: bash
   :caption: 检查zpool状态

显示输出:

.. literalinclude:: zfs_virtual_disks/zpool_satus_output
   :language: bash
   :caption: 检查zpool状态输出


参考
======

- `ZFS/Virtual disks <https://wiki.archlinux.org/title/ZFS/Virtual_disks>`_
