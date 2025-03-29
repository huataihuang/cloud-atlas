.. _speed_up_mdadm_rebuild_resyn:

=====================================
加速 ``mdadm`` 软RAID的重建和重同步
=====================================

在完成 :ref:`mdadm_raid10` 之后，检查 ``mdstat`` :

.. literalinclude:: mdadm_raid10/mdstat
   :caption: 检查md状态

可以看到 ``md10`` 在缓慢地 ``rsync`` :

.. literalinclude:: mdadm_raid10/mdstat_output
   :caption: 检查md状态可以看到RAID正在构建
   :emphasize-lines: 4

这个同步时间在海量存储上非常缓慢: 例如 12块 :ref:`nvme` 构建的 :ref:`mdadm_raid10` ，同步速度只有 200M/s 速度，预计需要 30 小时 (1803.0min)

``/proc/sys/dev/raid/{speed_limit_max,speed_limit_min}`` 内核参数
===================================================================

``/proc/sys/dev/raid/speed_limit_max`` 是导致同步缓慢的关键，默认值是  ``200000`` (20w，也就是转换成200MB) ， 而 ``/proc/sys/dev/raid/speed_limit_min`` 默认值是 ``1000`` 

.. literalinclude:: speed_up_mdadm_rebuild_resyn/change_raid_speed_limit
   :caption: 修改RAID同步速度，放大10倍

然后再次观察 ``mdstat`` 就可以看到同步速度大约增加了5倍(大约900MB/s)，预计同步只需要6个小时(371.9min):

.. literalinclude:: speed_up_mdadm_rebuild_resyn/mdstat_output
   :caption: 调整RAID同步速度，放大10倍后，同步速度加快到5倍
   :emphasize-lines: 4

.. note::

   对于现代SSD存储，默认的 ``mdadm`` 配置同步速率限制 ``speed_limit_max`` 已经不太合适，所以对于高性能存储，建议放大这个限速。这个限速也是导致RAID同步(修复或校验)缓慢的主要原因。

其他措施
===========

.. note::

   以下的加速措施我没有实践过，仅做记录，也许有机会可以再尝试...

设置MD设备 ``read-ahead``
---------------------------

- 设置每个MD设备 ``readahead`` (以 ``512字节`` 扇区为单位递增)，可以加速同步性能:

.. literalinclude:: speed_up_mdadm_rebuild_resyn/blockdev_readahead
   :caption: 配置MD设备 ``readahead`` 可以加速同步速度

设置RAID5或RAID6 ``stripe-cache_size``
-------------------------------------------

对于( **仅适用于** )RAID5和RAID6，通过调整条带缓存(stripe cache)大小(以每个设备的页为单位)可以将同步性能提高 3-6 倍。注意，该条带缓存用于同步阵列的所有写操作以及阵列降级时的所有读操作。

条带缓存的默认值是 256 ，调整范围是 17 到 32768 。在某些情况下，增加条带缓存可以提高性能，但是会占用一定的系统内存。

.. warning::

   条带缓存值设置过高可能会导致系统出现 "out of memory" 情况，所以需要按照以下公式计算:

   .. literalinclude:: speed_up_mdadm_rebuild_resyn/stripe-cache_memory_consumed
      :caption: 计算条带缓存消耗的内存

.. literalinclude:: speed_up_mdadm_rebuild_resyn/stripe_cache_size
   :caption: 设置RAID5/RAID6的MD设备条带化缓存

.. note::

   `5 Tips To Speed Up Linux Software Raid Rebuilding And Re-syncing <https://www.cyberciti.biz/tips/linux-raid-increase-resync-rebuild-speed.html>`_ 还提供了两个建议:

   - Disable NCQ on all disks
   - Bitmap Option

   但是目前没有找到佐证资料，暂时忽略

实践警告
==========

我在生产环境中的实践，实际上遇到一个非常糟糕的情况: 即使是默认的 ``{speed_limit_max,speed_limit_min}`` ，系统也会因为 :ref:`raid-check` 导致读写延迟(应用监控可以看到RT明显增加)。

这个现象似乎和理论上SSD :ref:`nvme` 高性能不一致，在 `Linux software RAID resync speed limits are too low for SSDs <https://utcc.utoronto.ca/~cks/space/blog/linux/SoftwareRaidResyncOnSSDs>`_ 提到过:

- 实践中，某些SSD在大规模重新同步时持续写入的性能不佳(例如 SanDisk 64GB SSD ``SDSSSDP06`` )
- 替换的磁盘如果之前被使用过，当数据同步时，SSD会忙于擦除闪存块而导致性能极为低下

我非常怀疑是底层物理磁盘的firmware存在bug或者硬件本质上存在缺陷

参考
=======

- `5 Tips To Speed Up Linux Software Raid Rebuilding And Re-syncing <https://www.cyberciti.biz/tips/linux-raid-increase-resync-rebuild-speed.html>`_
- `Linux software RAID resync speed limits are too low for SSDs <https://utcc.utoronto.ca/~cks/space/blog/linux/SoftwareRaidResyncOnSSDs>`_
- `OceanStor V500R007 Performance Monitoring Guide <https://support.huawei.com/enterprise/en/doc/EDOC1000181485/ddbc0e8b/optimizing-block-device-parameter-settings-of-linux>`_ 提到的方法也是通用方法: 1. 磁盘队列深度 2. 磁盘调度策略 3. 预取卷数据(read ahead) 4. I/O对齐 (4k对齐)
