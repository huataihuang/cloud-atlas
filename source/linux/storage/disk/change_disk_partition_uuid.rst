.. _change_disk_partition_uuid:

=============================
修改磁盘和分区的UUID
=============================

我在 :ref:`backup_restore_pi_by_tar` 过程中，需要修改SD卡的磁盘分区UUID:

- 原先 :ref:`pi_5_nvme_boot` 时是通过 ``dd`` 命令clone磁盘的，导致NVMe磁盘和SD卡的磁盘UUID和PARTUUID完全一致
- 当需要从SD卡启动时，两个磁盘UUID一致会导致即使设置了SD卡启动也会将NVMe的分区挂载为根分区(因为NVMe性能更快，所以相应UUID挂载会先于SD卡)

``fdisk`` 修改msdos分区UUID
==============================

``fdisk`` 提供了 ``x`` 命令 ( ``export`` )，在这个命令下一级子命令提供了 ``i`` 命令来修订分区ID:

.. literalinclude:: change_disk_partition_uuid/fdisk_partuuid
   :caption: fdisk修订msdos分区ID
   :emphasize-lines: 25,27,29,33,35

``gdisk`` 修改GPT分区UUID
===========================

.. note::

   这段我还没有实践，以后有机会试试

.. literalinclude:: change_disk_partition_uuid/gdisk_partuuid
   :caption: gdisk修订GPT分区ID

``tune2fs`` 修改磁盘UUID
===========================

.. note::

   这段我还没有实践，以后有机会试试

.. literalinclude:: change_disk_partition_uuid/tune2fs_diskuuid
   :caption: tune2fs修订磁盘UUID

参考
==========

- `How to change PARTUUID? <https://askubuntu.com/questions/1250224/how-to-change-partuuid>`_
- `How to change filesystem UUID (2 same UUID)? <https://unix.stackexchange.com/questions/12858/how-to-change-filesystem-uuid-2-same-uuid>`_
