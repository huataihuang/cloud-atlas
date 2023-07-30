.. _rsync:

============
rsync
============

快速起步
==========

早期我在在哦目录同步的时候，常常要记住 ``rsync`` 的一长串参数，不过，其实最常用的参数已经浓缩成 ``-a`` 了。也就是说，通常只要使用 ``rsync -a`` 就足够了::

   rsync -a <dir1>/ <dir2>

对比目录
==========

``rsync`` 的 ``--dry-run`` 参数可以模拟对比，但不实际同步数据，通常用于对比两个目录差异:

.. literalinclude:: rsync/rsync_compare_directory
   :caption: 使用rsync对比两个目录

比较两个目录，差异部分复制到第三个目录
======================================

这个方法有点巧妙，但是在一次故障处理中发现，这个场景还是很有用的:

- 有两个磁盘A和B，需要将A磁盘中数据备份出来，但是B磁盘空间比A小
- 假设已经做过 A => B 的rsync，但是目标磁盘空间不足，或者随着业务增长，已经无法完全将A同步到B
- 此时如果能把差异部分备份到C，则可以充分利用 B 和 C磁盘空间

.. note::

   不过，这个方法有点小复杂，维护起来还是有点奇怪。通常在一个物理主机上，多块磁盘可以通过 :ref:`striped_lvm` 连接成一个大磁盘。同样可以使用 :ref:`extend_ext4_on_lvm` 扩展B+C磁盘的LVM。(推荐使用 :ref:`xfs` 扩展更方便成熟)

- ``--compare-dest`` 提供了指定对比磁盘功能(但是复制到第三块磁盘上):

.. literalinclude:: rsync/rsync_compare-dest
   :caption: 对比磁盘A和B，差异数据复制到磁盘C

.. _parallel_rsync:

并行rsync同步
===============

企业级 :ref:`nvme` 磁盘空间非常巨大，往往是数TB空间，对于海量小文件的备份和恢复，则非常具有挑战性。我个人经验是，要根据业务情况进行分目录并发进行:

- 每个 ``rsync`` 在同步时会完全吃掉一个CPU core，所以要根据自己服务器的硬件情况(多少个CPU核心来决定并发数量)
- 对于海量小文件的系统，通常业务也会通过哈希方式分布数据到大量的子目录中(甚至是层级的海量目录)，所以要编写一个脚本来根据备份目录下的子目录进行划分给不同的 ``rsync`` 同时进行同步
- 运行 ``rsync`` 时采用 :ref:`screen` 的 ``-dm`` 参数运行，并且采用 ``-av`` 参数以便记录同步进度方便检查



参考
=======

- `How to rsync a directory to a new directory with different name? <https://unix.stackexchange.com/questions/178078/how-to-rsync-a-directory-to-a-new-directory-with-different-name>`_
- `compare 2 directories and copy differences in a 3rd directory <https://serverfault.com/questions/506005/compare-2-directories-and-copy-differences-in-a-3rd-directory>`_
- `How to Compare Local and Remote Directories <https://www.baeldung.com/linux/compare-local-and-remote-directories>`_
