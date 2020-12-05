.. _jetson_swap:

==================
Jetson Nano的swap
==================

Jetson Nano使用的L4T定制版Ubuntu操作系统，默认启用了2G大小的swap。但是在 :ref:`arm_k8s_deploy` 需要关闭swap。此时你会发现，原来系统并没有像我们常见的Linux系统一样，在 ``/etc/fstab`` 中添加 ``swap`` 挂载配置。

原来Jetson使用的定制Linux采用了zram来创建swap，这样可以在内存中以压缩方式存储内存页。建议将 ``zram-to-memory`` 设置为内存的1/2。

要修改这个配置，需要修改启动脚本 ``/etc/systemd/nvzramconfig.sh`` ，或者使用 ``nvzramconfig`` 脚本修改 ``/dev/zram*`` 文件，即使用 ``mkswap/swapon`` 来修改。

.. note::

   zram是在内存中划分出部分作为swap，并且采用压缩方式存储的内存型swap。

如果需要挂载更多swap，可以采用基于磁盘的swap来代替zram，例如在SSD磁盘上创建swap。

.. note::

   在Jetson Nano中使用zram只能在内存中使用swap，实际上限制了可用swap空间。对于运行大型深度学习模型或者编译非常大型的软件，会导致没有足够内存而失败。所以，必要情况下，我们需要通过使用磁盘swap文件来解决这个问题。

   JetsonHacksNano网站提供了一个 `installSwapfile脚本 <https://github.com/JetsonHacksNano/installSwapfile>`_ 帮助解决这个问题。

zram在Fedora 33+之后引入，请参考 :ref:`zram` 配置。

在Jetson上，可以看到配置了一个 ``/etc/systemd/system/nvzramconfig.service`` 服务，使用了 ``/etc/systemd/nvzramconfig.sh`` 脚本在启动时设置的zram swap。

- 检查zram swap::

   zramctl

可以看到输出显示有4个设备::

   NAME       ALGORITHM DISKSIZE DATA COMPR TOTAL STREAMS MOUNTPOINT
   /dev/zram3 lzo         495.5M   4K   76B   12K       4 [SWAP]
   /dev/zram2 lzo         495.5M   4K   76B   12K       4 [SWAP]
   /dev/zram1 lzo         495.5M   4K   76B   12K       4 [SWAP]
   /dev/zram0 lzo         495.5M   4K   76B   12K       4 [SWAP]

关闭 zram swap ::

   swapoff /dev/zram3

然后检查 ``zramctl`` 可以看到已经卸载了 ``/dev/zram3`` ::

   NAME       ALGORITHM DISKSIZE DATA COMPR TOTAL STREAMS MOUNTPOINT
   /dev/zram3 lzo         495.5M   4K   76B   12K       4
   /dev/zram2 lzo         495.5M   4K   76B   12K       4 [SWAP]
   /dev/zram1 lzo         495.5M   4K   76B   12K       4 [SWAP]
   /dev/zram0 lzo         495.5M   4K   76B   12K       4 [SWAP]

然后我们热移除上述zram3::

   echo 3 > /sys/class/zram-control/hot_remove

再次检查 ``zramctl`` 输出可以看到 ``zram3`` 已经消失::

   NAME       ALGORITHM DISKSIZE DATA COMPR TOTAL STREAMS MOUNTPOINT
   /dev/zram2 lzo         495.5M   4K   76B   12K       4 [SWAP]
   /dev/zram1 lzo         495.5M   4K   76B   12K       4 [SWAP]
   /dev/zram0 lzo         495.5M   4K   76B   12K       4 [SWAP]

重复以上命令卸载掉所有zram swap::

   swapoff /dev/zram2
   echo 2 > /sys/class/zram-control/hot_remove
   swapoff /dev/zram1
   echo 1 > /sys/class/zram-control/hot_remove
   swapoff /dev/zram0
   echo 0 > /sys/class/zram-control/hot_remove


最后检查 ``zramctl`` 输出就是空白的。

使用 ``top`` 命令检查也就看不到swap

- 最后不要忘记关闭掉systemd启动的服务::

   systemctl disable nvzramconfig.service

参考
======

- `Jetpack 4.2.3 has a built in 2GB swap file we are not able to increase this to 4 GB <https://forums.developer.nvidia.com/t/jetpack-4-2-3-has-a-built-in-2gb-swap-file-we-are-not-able-to-increase-this-to-4-gb/108324>`_
- `Jetson Nano – Use More Memory! <https://www.jetsonhacks.com/2019/04/14/jetson-nano-use-more-memory/>`_
