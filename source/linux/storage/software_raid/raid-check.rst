.. _raid-check:

==================
raid-check
==================

在完成 :ref:`mdadm_raid10` 之后，运维过程中发现默认系统配置了每周一次 ``raid-check`` ，也就是在 :ref:`cron` 配置了一个 ``/etc/cron.d/raid-check`` :

.. literalinclude:: raid-check/cron
   :caption: 默认配置每周日凌晨1点进行 ``raid-check``

在实际生产环境中，由于现代存储容量非常巨大(单块 :ref:`nvme` 容量达到4T，组合 :ref:`mdadm_raid10` 达到数十T)，这个 ``mdadm`` 的检查耗时会非常长:

- 默认同步速度限制为 ``200MB/sec`` (可修改，但是我踩了一个 :ref:`md_sync_speed` 调整的坑 )，此时观察 ``top`` 输出:

.. literalinclude:: raid-check/top_output
   :caption: 在 ``raid-check`` 是观察 ``top`` 输出
   :emphasize-lines: 7

可以看到 ``md10_resync`` 始终处于 ``D`` 状态

- 检查 ``md10`` 可以看到状态正常，且正在 ``check`` :

.. literalinclude:: raid-check/mdadm_status
   :caption: 使用 ``mdadm -D`` 可以检查RAID状态

输出显示:

.. literalinclude:: raid-check/mdadm_status_output
   :caption: 使用 ``mdadm -D`` 可以检查RAID状态，当先显示正在 ``check``
   :emphasize-lines: 14

排查
======

在生产环境中，当每周末1点启动 ``raid-check`` 之后，业务繁忙期间会出现较高的延迟(大约是正常状态的2倍，也就是 20ms => 40ms)

- 检查服务器 :ref:`md_sync_speed` ， ``md`` 设备同步速度:

.. literalinclude:: md_sync_speed/md_sync_speed_max
   :caption: 检查 ``md`` 设备 ``md10`` 的 ``sync_speed_max`` 限速

默认值是 ``200000`` 也就是 ``200MB/s`` :

.. literalinclude:: md_sync_speed/md_sync_speed_max_output
   :caption: ``md`` 设备默认 ``sync_speed_max`` 限速是 ``200MB/s``

- 观察服务器 ``top`` 输出，可以看到 ``md10_resync`` 持续 ``D`` 状态，但是 ``iowait`` 始终是 **0**

.. literalinclude:: raid-check/top_output
   :caption: 默认 :ref:`md_sync_speed` 服务器的 ``md10_resync`` 始终 ``D`` 状态 **非常异常**

- 检查 ``md10_resync`` 进程堆栈:

.. literalinclude:: raid-check/md10_resync_stack
   :caption: 通过 ``/proc`` 获取 ``md10_resync`` 的进程堆栈

- 通过 :ref:`sysrq` 获取系统所有D状态dump:

.. literalinclude:: raid-check/sysrq_dump
   :caption: dump素有blocked (D)状态的任务

- 不幸的是，陷入 ``D`` 状态的 ``md10_resync`` 无法杀死，即使使用了 ``kill -9 47438`` 也不行

- 我尝试将同步速度降低到 ``0`` ，结果发现最低实际上是 ``2MB/s`` :

.. literalinclude:: raid-check/limit_md_sync_speed_0
   :caption: 限制同步速度到0，实际结果是 ``2MB/s``
   :emphasize-lines: 2,8

而且，即使限速以后， ``md10_resync`` 依然是 ``D`` 状态，也无法停止

也就是说，一旦启动了 ``raid-check`` 就无法停止了? **不是的**

控制 ``mdadm`` 的操作是通过 :ref:`md_sync_action` 来实现的，通过向 ``sync_action`` 发出 ``idle`` 指令，就能停止:

参考
======

- `Weekly RAID check affecting my system - any way to mitigate? <https://serverfault.com/questions/1100760/weekly-raid-check-affecting-my-system-any-way-to-mitigate>`_
- `mdadm RAID5 RAID6 how to check consistency on running array <https://serverfault.com/questions/1064838/mdadm-raid5-raid6-how-to-check-consistency-on-running-array>`_
- `Check RAID software: my status <https://serverfault.com/questions/721364/check-raid-software-my-status>`_
- `Mdadm recovery and resync <https://www.thomas-krenn.com/en/wiki/Mdadm_recovery_and_resync>`_
