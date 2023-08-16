.. _mdadm_remove_md:

=====================
mdadm删除md
=====================

在 :ref:`mdadm_raid10` 有一个乌龙误操作，使用了整个磁盘，而不是磁盘分区来构建RAID，不符合 :ref:`mdadm_partion_vs_disk` 规划，所以准备推倒重来:

- RAID上还没有创建文件系统和挂载，所以跳过 ``umount /dev/md10``

- 检查 ``mdadm`` RAID设备:

.. literalinclude:: mdadm_raid10/mdstat
   :caption: 检查 md 设备状态

输出显示:

.. literalinclude:: mdadm_remove_md/mdstat_output
   :caption: 检查 md 设备状态 显示内容

- 停止md设备:

.. literalinclude:: mdadm_remove_md/mdadm_stop
   :caption: 停止 ``md10`` 设备

此时再次检查 ``mdstat`` :

.. literalinclude:: mdadm_raid10/mdstat
   :caption: 检查 md 设备状态

显示状态如下:

.. literalinclude:: mdadm_remove_md/mdadm_stop_mdstat
   :caption: 停止 ``md10`` 设备之后的 ``mdstat``

- 尝试移除RAID设备:

.. literalinclude:: mdadm_remove_md/mdadm_remove_md
   :caption: 尝试移除(删除) ``md10``

提示没有这个设备:

.. literalinclude:: mdadm_remove_md/mdadm_remove_md_error
   :caption: 尝试移除(删除) ``md10`` 出错，显示没有这个设备文件

- 移除超级块(Superblocks):

.. literalinclude:: mdadm_remove_md/mdadm_zero-superblock
   :caption: 移除磁盘设备超级块

.. note::

   移除超级块的命令应该也可以通过 ``dd`` 来实现::

      dd if=/dev/zero of=/dev/nvme0n1 bs=1M count=1024

- 再次检查 ``mdstat`` :

.. literalinclude:: mdadm_raid10/mdstat
   :caption: 检查 md 设备状态

比较奇怪，我看到md10还在 ``mdstat`` 中显示，和之前stop之后一样:

.. literalinclude:: mdadm_remove_md/mdadm_stop_mdstat
   :caption: 移除磁盘超级块之后还是看到 [raid10] ，我尝试重启

参考
=======

- `Removal of mdadm RAID Devices – How to do it quickly? <https://bobcares.com/blog/removal-of-mdadm-raid-devices/>`_
- `Mdadm – How can i destroy or delete an array : Memory, Storage, Backup and Filesystems <https://kogitae.fr/mdadm-how-can-i-destroy-or-delete-an-array-memory-storage-backup-and-filesystems.htm>`_
