.. _zram:

=================================
zram - 基于内存的压缩块存储设备
=================================

zram是一个Linux内核模块，可以用来创建最高5:1压缩率的基于RAM的块设备。zram设备可以和其他块设备一样使用。通常zram被用于作为swap设备来扩展主机内存。它们也可以用来存储 ``/tmp`` 并且用于作为一个压缩性RAM设备。

Fedora 33+ 使用系统内存的一半来创建一个zram swap设备，并且限制最大使用4GB空间，使用的工具名为 ``zram-generator`` 。

.. note::

   现代大规模集群的日志采集是分析集群性能的重要基础，由于日志采集写磁盘非常消耗系统资源并且效率低下，如果能够实现日志即时传输出去，就不需要持久化存储(磁盘)，完全可以使用 ``tmpfs``  来存储日志。

   在 ``tmpfs`` 上结合 ``zram`` ，就可以大幅度压缩 ``tmpfs`` 占用的内存空间，把宝贵的内存用于应用系统。所消耗的只是压缩处理的cpu资源，通常系统cpu资源都有剩余，所以这种架构对于大型集群的日志采集应该是有很大帮助。我后续会做一个实践汇总。

.. note::

   :ref:`jetson_nano` 官方操作系统 L4T 的 :ref:`jetson_swap` 就是采用zram来实现的。

zram基本使用
==============

``zram`` 内核模块必须在使用zram之前加载，可以通过 ``modprobe zram`` 加载，不过默认只有1个zram设备。如果你希望创建4个zram设备，则使用 ``modprobe zram num_devices=4`` 。

也可以通过创建 ``/etc/modprobe.d/zswap.conf`` 配置实现::

   options zram num_devices=4

- 基本使用方法::

   modprobe -v zram
   echo zstd > /sys/block/zram0/comp_algorithm
   echo 2G > /sys/block/zram0/disksize
   mkswap /dev/zram0
   swapon /dev/zram0

此时检查::

   cat /proc/swaps

可以看到::

   Filename                Type        Size      Used  Priority
   /dev/zram0              partition   2097148   0     5

创建设备
=========

zram设备可以创建为 ``/dev/zram0`` ， ``/dev/zram1`` 依次类推。添加的设备数量可以通过读取 ``/sys/class/zram-control/hot_add`` 来获得::

   cat /sys/class/zram-control/hot_add

例如当前设备数量4个::

   4

- 压缩算法可以通过 ``/sys/block/zram0/comp_algorithm`` 获得::

   cat /sys/block/zram0/comp_algorithm

输出::

   [lzo] deflate

这个算法可能包含 ``lzo lzo-rle lz4 lz4hc 842 [zstd]``

zram设备的空间大小初始化时候是0，直到你修改容量(只需要echo一个数值到 ``/sys/block/zram{devicenumber}/disksize`` )，单位可以是K,M,G::

   echo 512M > /sys/block/zram0/disksize
   echo 1G > /sys/block/zram1/disksize

.. note::

   zram不会使用任何实际内存，直到设备开始填充数据。举例，一个2GB的zram设备存储了5.8MB数据，压缩以后数据实际只有443.9K，仅使用780K存储空间，而不会使用2GB内存。

zram块设备初始化成基于RAM的压缩swap，只需要使用 ``mkswap`` 初始化设备，然后用 ``swapon`` 激活。使用 ``swapon`` 参数 ``-p 32767`` 将给予zram设备最高优先级::

   mkswap /dev/zram0
   swapon /dev/zram0 -p 32767

删除zram设备
=============

当zswap设备在使用时你不能删除它，需要首先umount文件系统或者swap设备，然后通过 ``/sys/class/zram-control/hot_remove`` 来移除::

   swapoff /dev/zram0
   echo 0 > /sys/class/zram-control/hot_remove

检查设备
=========

参考
======

- `LinuxReviews docs: Zram <https://linuxreviews.org/Zram>`_
