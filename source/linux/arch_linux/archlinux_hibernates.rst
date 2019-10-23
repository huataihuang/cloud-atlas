.. _archlinux_hibernates:

=========================
Arch Linux Hibernates
=========================

在 :ref:`archlinux_on_mbp` 采用的是双操作系统，由于工作原因，需要经常在macOS和Linux之间切换，如果每次重新登陆到Linux操作系统，都要重头开始准备工作环境会非常繁琐(例如打开同样的编辑器和编辑文件，浏览器以及终端)。采用 Hibernages 可以将运行状态存储到磁盘中，这样下次切换到Linux就可以立即恢复到离开时的状态，提高了工作效率。

.. note::

   我在 :ref:`ubuntu_hibernate` 实践中也有一些经验可以参考。

电源管理
=============

Linux支持3中不同的挂起系统模式：

- suspend to RAM(也称为suspend): 切断主机大多数部件的电源，但保持RAM电力，这样RAM可以存储主机的状态。由于维持内存的电力消耗很小，所以suspend可以让笔记本电池较长时间供电，并且恢复运行非常迅速。
- suspend to disk(也称为hibernate): 通过swap磁盘来保存主机状态，这样就可以不需要电源，完全不消耗电池的电能。缺点是恢复速度比suspend慢，但是可以切换到其他操作系统(例如双启动的macOS)而不会丢失原先的运行状态。
- suspend to both(也称为hybrid suspend): 同时将主机状态保存在内存和磁盘swap上，但不断开电能供应。如果电池够用，则直接从RAM恢复系统(速度最快)，如果电池电能耗尽，则从磁盘恢复主机状态(速度较慢)。虽然后者比从内存恢复要慢很多，但是在电池电能耗尽情况下依然能够保证主机状态不丢失。

底层接口
=============

.. note::

   虽然可以直接使用底层接口实现suspend/hibernate，并且速度较快，但是高层接口可以实现pre-和post-suspend hooks，例如设置硬件时钟，恢复无线网络等。

内核级接口(swsusp)
------------------

在内核的 ``/sys/power/state`` 接口写入相应字符串可以触发suspend

用户级软件设置(uswsusp)
------------------------

uswsusp("Userspace Software Suspend")是包装了内核suspend-to-RAM机制，提供在suspsend和resume时候执行一些图形卡配置。

高层接口
============

systemd
------------

systemd原生提供了suspend, hibernate 和 hybrid 支持，这也是Arch Linux使用的默认接口。

hibernation
~~~~~~~~~~~~~~~

要使用hibernate，需要创建swap磁盘，并且在内核启动参数 ``resume=`` 中指定内核使用swap，也就是需要配置 initramfs 来告诉内核从用户空间指定的swap恢复。

对于swap分区小于RAM，依然能够实现hibernate：

``/sys/power/image_size`` 控制了 ``suspend-to-disk`` 机制创建的镜像大小，这个值是一个非负的整数，默认设置为内存的 2/5 。

需要的内核参数
~~~~~~~~~~~~~~~~~

需要使用内核参数 ``resume=swap_device`` ，这里的 ``swap_device`` 是持久化块设备命名，例如::

   resume=UUID=4209c845-f495-4c43-8a03-5363dd433153
   resume="PARTLABEL=Swap partition"
   resume=/dev/archVolumeGroup/archLogicalVolume  (如果是LVM逻辑卷)

待续...

参考
=====

- `Power management/Suspend and hibernate <https://wiki.archlinux.org/index.php/Power_management/Suspend_and_hibernate>`_
