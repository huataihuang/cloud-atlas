.. _ext4_fsck:

===================
EXT4文件系统fsck
===================

手工 ``fsck``
=================

文件系统检查和修复工具 ``fsck`` 有以下运行要求:

- 文件系统 ``fsck`` 时必须确保是非挂载状态(挂载状态执行 ``fsck`` 会导致文件系统损坏)
- 如果没有传递给 ``fsck`` 参数，则会检查 ``/etc/fstab`` 文件中的列出设备
- ``fsck`` 命令实际上是不同Linux文件系统检查器( ``fsck.*`` )的包装，实际上根据文件系统类型会调用不同的选项

手工执行检查::

   sudo umount /dev/sdc1

   sudo fsck -p /dev/sdc1

参数 ``-p`` 可以使得 ``fsck`` 自动修复任何发现问题而无需用户干预。

修复完成后，可以重新挂载文件系统::

   sudo mount /dev/sdc1

启动时检查文件系统
======================

大多数Linux发行版，会在系统被标记为 ``dirty`` 或者重启一定次数后自动在启动时执行 ``fsck`` 

.. note::

   我在解决了 :ref:`jetson_pcie_err` 之后发现 ``Ext4-fs`` 文件系统报错，促使我尝试检查和修复根文件系统

- 检查当前挂载次数，检查间隔以及最新的fsck检查，需要使用 ``tune2fs`` 工具::

   tune2fs -l /dev/mmcblk0p1 | grep -i 'last checked\|mount count'

显示::

   Mount count:              21
   Maximum mount count:      -1
   Last checked:             Sat Feb 20 10:56:51 2021

这里 ``Maximum mount count`` 表示当文件系统挂载达到这个数值后将在启动时 ``fsck`` 文件系统，但是如果这个值是 ``0`` 或者 ``-1`` 就永远不会 ``fsck``

- 如果希望文件系统每挂载 ``25`` 次之后就运行一次 ``fsck`` 则设置::

   sudo tune2fs -c 25 /dev/mmcblk0p1

- 也可以设置两次检查之间间隔，例如设置1个月运行一次::

   sudo tune2fs -i 1m /dev/mmcblk0p1

- 对于使用 ``systemd`` 的现代发行版，只需要内核传递参数::

   fsck.mode=force
   fsck.repair=yes

就可以强制在操作系统启动时执行 ``fsck`` 。例如，对于 :ref:`ubuntu_linux` 系统，修改 ``/etc/default/grub`` 配置::

   GRUB_CMDLINE_LINUX_DEFAULT="... fsck.mode=force fsck.repair=yes"

然后执行::

   sudo update-grub

生成新的grub配置后重启，就能在重启后自动进行 ``fsck``

不过，对于早期版本，例如Ubuntu 18.04 ，上述方法无效(虽然也使用 ``systemd`` )，则需要存在 ``/forcefsck`` 文件才能启动时进行 ``fsck`` ::

   sudo touch /forcefsck

``fstab`` 选项
===============

``/etc/fstab`` 配置了文件系统挂载，其中最后一列参数决定了 ``fsck`` 顺序和是否进行 ``fsck`` ::

   # [File System] [Mount Point] [File System Type] [Options] [Dump] [PASS]
   /dev/sda1       /             ext4               defaults  0      1
   /dev/sda2       /home         ext4               defaults  0      2
   server:/dir     /media/nfs    nfs                defaults  0      0

最后一列，也就是第 ``6`` 列( ``[PASS]`` )选项表示文件系统检查的顺序:

- ``0`` - 不检查
- ``1`` - 文件系统将首先检查并且只在同一时间只能做这一个检查
- ``2`` - 所有标记 ``2`` 的文件都是放在标记 ``1`` 的文件系统之后再做检查，并且可以并行检查

.. note::

   根文件系统必须设置成 ``1`` ，其他文件系统可以设置成 ``2``

参考
======

- `Fsck Command in Linux (Repair File System) <https://linuxize.com/post/fsck-command-in-linux/>`_
- `How to Check and Repair EXT4 Filesystem in Linux <https://www.2daygeek.com/fsck-repair-corrupted-ext4-file-system-linux/>`_
