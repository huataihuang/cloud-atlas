.. _incus_storage_volumes:

=========================
Incus 存储卷
=========================

Incus支持多种存储后端，包括 :ref:`incus_lvm` 和 :ref:`incus_zfs` ，通过一种统一的存储卷管理来实现

创建一个custom存储卷
========================

.. note::

   实际上在 :ref:`incus_zfs` 上，Incus规划了几种存储目录来管理不同用途的文件系统或 :ref:`zvol` 卷，这里 ``custom存储卷`` 实际上就是创建在 ``incus-zpool/custom`` 目录下的 ``zvol`` 。虽然我也能把 :ref:`zvol` 创建到其他目录下，例如给虚拟机使用的，可以创建到 ``incus-zpool/virtual-machines/`` 目录下，不过，按照官方文档， ``incus storage volume create <pool_name> <volume_name>`` ，这里的 ``pool_name`` 是incus的存储池，默认是 ``default`` 存储池(底层就是zfs的zpool)。

- 创建3个 :ref:`zvol` 存储卷:

.. literalinclude:: incus_storage_volumes/create
   :caption: 创建3个zvol存储卷

- 检查卷:

.. literalinclude:: incus_storage_volumes/list
   :caption: 检查卷
  
输出可以看到刚创建的3个 :ref:`zvol` :

.. literalinclude:: incus_storage_volumes/list_output
   :caption: 检查卷
   :emphasize-lines: 6,8,10

将卷添加到实例
=====================

- 将块设备添加到虚拟机实例:

.. literalinclude:: incus_storage_volumes/attach
   :caption: 添加块设备到虚拟机

此时在虚拟机 ``debian13-dev`` 中执行 ``fdisk -l`` 就能看到添加的3个磁盘设备:

.. literalinclude:: incus_storage_volumes/fdisk_output
   :caption: 在虚拟机内部观察到的磁盘设备
   :emphasize-lines: 2,9,16

参考
========

- `Incus documentation: How to manage storage volumes <https://linuxcontainers.org/incus/docs/main/howto/storage_volumes/>`_
