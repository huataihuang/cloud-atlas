.. _zfs-stats:

==================
zfs-stats
==================

``zfs-stats`` 工具提供了非常丰富的参数，通过不同选项来精细化观察 ZFS 的各项内核统计数据       

- 不带任何参数 ``zfs-stats`` 会全面输出全部统计信息

- 观察ARC缓存( ``-A`` ):

.. literalinclude:: zfs-stats/arc
   :caption: 观察ARC缓存

输出信息非常清晰:

.. literalinclude:: zfs-stats/arc_output
   :caption: 观察ARC缓存

- 查看 L2ARC(二级缓存)状态

.. literalinclude:: zfs-stats/l2arc
   :caption:  L2ARC(二级缓存)状态

- 查看 DMU 预读( ``zfetch`` )统计

.. literalinclude:: zfs-stats/zfetch
   :caption: DMU 预读(zfetch)统计

输出类似

.. literalinclude:: zfs-stats/zfetch_output
   :caption: DMU 预读(zfetch)统计

- 查看vdev缓存状态:

.. literalinclude:: zfs-stats/vdev
   :caption: vdev缓存状态
