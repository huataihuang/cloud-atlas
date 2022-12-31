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

``util-linux`` 软件包提供了一个工具 ``zramctl`` 可以用来检查设备的真实压缩率以及其他信息，这些信息也可以通过 ``/sys/block/zram{devicenumber}/`` 目录下的文件提供。

.. _zram_swap_script:

使用zram作为swap的脚本
=======================

以下是一个简单的脚本用来创建zram swap设备，注意，这个脚本假设你还没有使用zram，并提供了启动的systemd配置:

- ``/usr/local/bin/zramswap-on`` :

.. literalinclude:: zram/zramswap-on
   :language: bash
   :linenos:

- ``/usr/local/bin/zramswap-off`` :

.. literalinclude:: zram/zramswap-off
   :language: bash
   :linenos:

- ``/etc/systemd/system/create-zram-swap.service`` :

.. literalinclude:: zram/create-zram-swap.service
   :language: bash
   :linenos:

- 然后执行服务配置加载和激活::

   systemctl daemon-reload
   systemctl enable --now create-zram-swap.service

zram压缩算法对比
===================

- 比较zram压缩算法的简单方法是向zram设备文件系统中复制大文件或者大量文件，观察不同压缩算法的zram设备耗时、压缩后空间

- 也可以通过设置zram设备作为swap，然后编译大型软件(如Chromium)来对比观察，例如在6GB总系统内存虚拟机中设置3GB zram swap，并添加HDD后端的swap来观察编译时间

性能影响
---------

根据 `LinuxReviews docs: Zram <https://linuxreviews.org/Zram>`_ 的测试，使用缓慢的旧型号Athlon 5350 APU with a slow HDD as a swap device in addition to a zram swap device 测试:

- 使用50%的物理内存配置为zram swap，得到的编译收益最大，不过zstd和lzo-rle两种算法差别不大

但是，使用新型 Ryzen 2600, 6 Cores/Threads (QEMU VM), 8 GiB RAM 设备，则配置2G zram swap得到性能收益(虽然不多)，但配置4G zram swap则性能下降。

.. note::

   使用zram的swap配置和具体硬件相关，可能需要做不断的验证测试才能找到合适比例。

zram工具
============

``util-linux`` 软件包提供的zramctl提供了设置和配置zram的功能

- 检查设备::

   zramctl

显示输出::

   NAME       ALGORITHM DISKSIZE DATA COMPR TOTAL STREAMS MOUNTPOINT
   /dev/zram3 lzo         495.5M   4K   76B   12K       4 [SWAP]
   /dev/zram2 lzo         495.5M   4K   76B   12K       4 [SWAP]
   /dev/zram1 lzo         495.5M   4K   76B   12K       4 [SWAP]
   /dev/zram0 lzo         495.5M   4K   76B   12K       4 [SWAP]

- zramctl提供了 ``-f`` 或 ``--find`` 选项可以用来找到第一个没有使用的zram设备，或创建一个新的zram设备。此外提供了 ``-s`` 或 ``--size`` 选项以及 ``-s`` 或 ``--algorithm`` 选项::

   zramctl --find --size 512M --algorithm zstd

.. _zram_generator:

zram-generator
=================

从Fedora 33+ 开始默认提供了一个 ``zram-generator`` 的工具 ，这个工具是 `systemd/zram-generator <https://github.com/systemd/zram-generator>`_

zram-generator 用于配置最大4GB zram ，或者是系统内存的一半。默认使用 ``lzo-rle`` 压缩算法。可以通过 ``/etc/systemd/zram-generator.conf`` 来覆盖默认的 ``/usr/lib/systemd/zram-generator.conf`` 配置。

- 举例 ``/etc/systemd/zram-generator.conf`` ::

   [zram0]
   # Use 20% of system memory for zswap. Default: 0.5
   zram-fraction = 0.2
   # Limits the maximum size. Set in MiB. 2048 means
   # it will never be larger than 2 GiB. Default: 4096
   max-zram-size = 2048

   # Fedora defaults to lzo-rle which is very inefficient
   # compared to vastly superior zstd compression
   compression-algorithm = zstd

zram-generator可以通过以下3种方式之一来禁用:

- 屏蔽运行::

   systemctl mask swap-create@.service

是的，确实是 ``swap-create@.service`` 而不是 ``zram-generator``

- 创建一个空的配置::

   echo > /etc/systemd/zram-generator.conf

- 卸载 ``zram-generator`` 和 ``zram-generator-defaults`` 软件包::

   dnf -y remove zram-generator zram-generator-defaults
   
参考
======

- `LinuxReviews docs: Zram <https://linuxreviews.org/Zram>`_
