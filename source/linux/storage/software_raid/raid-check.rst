.. _raid-check:

==================
raid-check
==================

在完成 :ref:`mdadm_raid10` 之后，运维过程中发现默认系统配置了每周一次 ``raid-check`` ，也就是在 :ref:`cron` 配置了一个 ``/etc/cron.d/raid-check`` :

.. literalinclude:: raid-check/cron
   :caption: 默认配置每周日凌晨1点进行 ``raid-check``

在实际生产环境中，由于现代存储容量非常巨大(单块 :ref:`nvme` 容量达到4T，组合 :ref:`mdadm_raid10` 达到数十T)，这个 ``mdadm`` 的检查耗时会非常长:

- 默认同步速度限制为 ``200MB/sec`` (可修改，但是我踩了一个 :ref:`md_sync_speed` 调整的坑 )

参考
======

- `Weekly RAID check affecting my system - any way to mitigate? <https://serverfault.com/questions/1100760/weekly-raid-check-affecting-my-system-any-way-to-mitigate>`_
- `mdadm RAID5 RAID6 how to check consistency on running array <https://serverfault.com/questions/1064838/mdadm-raid5-raid6-how-to-check-consistency-on-running-array>`_
- `Check RAID software: my status <https://serverfault.com/questions/721364/check-raid-software-my-status>`_
