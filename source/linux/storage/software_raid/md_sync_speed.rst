.. _md_sync_speed:

=====================
``mdadm`` 同步速度
=====================

.. warning::

   当你调整系统默认配置时，务必充分理解参数含义以及影响，并做好详细记录。本文是 **我的一次经验教训总结**

我在 :ref:`mdadm_raid10` 实践时，由于服务器硬件规格极大，采用了 4TB 的 :ref:`nvme` ，所以在构建 ``RAID10`` 初始化RAID的 ``sync`` 同步非常耗时，原因是默认同步限速是 ``200MB/s`` ，对于海量存储来说完成首次全量同步可能会需要以天为计量单位。

例如，我的实践 :ref:`mdadm_raid10` ，刚完成 ``RAID10`` 构建时检查 ``mdstat`` :

.. literalinclude:: mdadm_raid10/mdstat
   :caption: 检查md状态

可以看到同步速度是 ``207272K/sec`` 也就是大约 ``200MB/s`` ，预估完成时间 ``1803min`` (30小时):

.. literalinclude:: mdadm_raid10/mdstat_output
   :caption: 检查md状态可以看到RAID正在构建

对于构建 :ref:`deploy_lvm_mdadm_raid10` 底层基础工作，虽然没有明显影响(raid同步时依然可以读写)，但是还是会带来一些不便(主要是想快速完成部署和验证 :ref:`gluster` 性能)

检查同步速度
=============

对于同步限制的主要参数调整是 ``md`` 设备 ``sync_speed_max``  ，这个参数可以通过 ``/sys/block/md10/md/sync_speed_max`` 检查:

- 检查 ``md`` 设备同步速度:

.. literalinclude:: md_sync_speed/md_sync_speed_max
   :caption: 检查 ``md`` 设备 ``md10`` 的 ``sync_speed_max`` 限速

默认值是 ``200000`` 也就是 ``200MB/s`` :

.. literalinclude:: md_sync_speed/md_sync_speed_max_output
   :caption: ``md`` 设备默认 ``sync_speed_max`` 限速是 ``200MB/s``

- 此外还有一个默认的 ``md_sync_speed_min`` :

.. literalinclude:: md_sync_speed/md_sync_speed_min
   :caption: 检查 ``md`` 设备 ``md10`` 的 ``sync_speed_min`` 最小同步速度(下限)

默认值是 ``1000`` 也就是 ``1MB/s`` :

.. literalinclude:: md_sync_speed/md_sync_speed_min
   :caption: 检查 ``md`` 设备 ``md10`` 的 ``sync_speed_min`` 最小同步速度(下限)

调整同步速度
==============

- 可以在线调整同步速度:

.. literalinclude:: md_sync_speed/adjust_md_sync_speed
   :caption: 在线调整 ``md`` 设备 ``md10`` 同步速率

.. warning::

   ``md`` 配置默认 ``200MB/s`` 同步速度是有一定道理的，我在这里踩了一个坑(见下文)

参考
======

- `5 Tips To Speed Up Linux Software Raid Rebuilding And Re-syncing <https://www.cyberciti.biz/tips/linux-raid-increase-resync-rebuild-speed.html>`_  这是一篇非常好的文档
