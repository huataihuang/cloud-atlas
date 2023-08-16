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

``/proc/sys/dev/raid/speed_limit_min`` 是导致同步缓慢的关键，默认值是 ``1000`` (KB)，( ``/proc/sys/dev/raid/speed_limit_max`` 默认值是 ``200000`` 20w )

.. literalinclude:: speed_up_mdadm_rebuild_resyn/change_raid_speed_limit
   :caption: 修改RAID同步速度，放大10倍

然后再次观察 ``mdstat`` 就可以看到同步速度大约增加了5倍(大约900MB/s)，预计同步只需要6个小时(371.9min):

.. literalinclude:: speed_up_mdadm_rebuild_resyn/mdstat_output
   :caption: 调整RAID同步速度，放大10倍后，同步速度加快到5倍
   :emphasize-lines: 4

其他加速方法...


参考
=======

- `5 Tips To Speed Up Linux Software Raid Rebuilding And Re-syncing <https://www.cyberciti.biz/tips/linux-raid-increase-resync-rebuild-speed.html>`_
