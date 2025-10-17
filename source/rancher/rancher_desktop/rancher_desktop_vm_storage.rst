.. _rancher_desktop_vm_storage:

============================
Rancher Desktop虚拟机存储
============================

我在检查 :ref:`rancher_desktop_vm` 发现一个有趣的现象:

.. literalinclude:: rancher_desktop_vm/df
   :caption: ``sudo df -h`` 输出
   :emphasize-lines: 5,11,12,27

- 根目录 ``/`` 是一个 ``tmpfs``
- ``/dev/disk/by-label/data-volume`` 磁盘分区被挂载成多个目录，并且分配了大约 ``98G`` 空间
- macOS的 ``/Users/admin`` (我的物理主机用户是 ``admin`` )目录被映射到虚拟机内部相同目录 ``/Users/admin``

上述存储分布是怎么实现的呢？明明虚拟机只有一个分区(100G)， ``fdisk -l`` 显示:

.. literalinclude:: rancher_desktop_vm_storage/fdisk
   :caption: ``fdisk -l`` 显示只有一个分区
   :emphasize-lines: 6

为什么要将一个分区反复挂载到不同的目录?

检查 ``mount`` 输出可以看到，同一个分区挂载到不同目录:

.. literalinclude:: rancher_desktop_vm_storage/mount
   :caption: 检查 ``mount`` 输出
   :emphasize-lines: 17-23,25
