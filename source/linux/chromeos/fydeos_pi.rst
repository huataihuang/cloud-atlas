.. _fydeos_pi:

==================================
在树莓派上运行Chromium OS(FydeOS)
==================================

`FydeOS <https://fydeos.com/>`_ 是国内团队基于 :ref:`chromium_os` 定制的操作系统，类似于商业版本的Chrome OS，大致的关系如下：

- Chromium OS作为开源操作系统，是一个深度定制的Linux操作系统，主要是面向Web用户。通过精简内核和应用组件， :ref:`chromium_os_arch` 实现了较高的安全特性
- FydeOS基于Chormium OS编译，并加入了非开源协议软件，所以类似Chrome OS，并不提供源代码
- FydeOS的GitHub网站提供了指导编译Chromium OS的文档，并且提供了在此基础上编译AnBox运行环境的指南。通过Anbox可以实现在Linux上运行Android应用程序，但是需要剥离Goolge Chrome的ARC+。FydeOS提供了一些开发指南。

.. note::

   我不确定FedeOS直接提供的镜像是不是也是采用AnBox来运行Android，也可能有其他解决方案。不过，我比较感兴趣的是实现的底层技术。所以我计划先安装FydeOS，然后自己编译Chromium OS和AnBox，进行对比。

安装FydeOS
============

FydeOS类似Chrome OS，采用了部分商业软件，所以不提供直接源代码。需要从 `FydeOS官方下载 <https://fydeos.com/download>`_ 安装镜像，下载以后解压缩为: ``FydeOS_for_you_Pi400_v11.4_SP2.img``

- 制作TF卡镜像::

   dd if=FydeOS_for_you_Pi400_v11.4_SP2.img of=/dev/sdb bs=100M

启动
=======

- 连接外接显示器(我的显示器是 ``HP E273q`` 分辨率 ``2560x1440`` )，开机后显示了树莓派著名的彩虹方块。但是很快就黑屏，显示没有信号输入。

我采用如下方法排查：

- 将TF卡通过读卡器连接到Linux主机上，通过 ``fdisk -l`` 可以看到如下分区::

   Disk /dev/sdc: 119.08 GiB, 127865454592 bytes, 249737216 sectors
   Disk model: MassStorageClass
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: gpt
   Disk identifier: 238E0445-14A2-B84B-B604-52D48974E97A
   
   Device       Start       End   Sectors   Size Type
   /dev/sdc1  5996544 249737115 243740572 116.2G Linux filesystem
   /dev/sdc2    20480     69631     49152    24M ChromeOS kernel
   /dev/sdc3   417792   5996543   5578752   2.7G ChromeOS root fs
   /dev/sdc4    69632    118783     49152    24M ChromeOS kernel
   /dev/sdc5   413696    417791      4096     2M ChromeOS root fs
   /dev/sdc6    16448     16448         1   512B ChromeOS kernel
   /dev/sdc7    16449     16449         1   512B ChromeOS root fs
   /dev/sdc8   118784    151551     32768    16M Linux filesystem
   /dev/sdc9    16450     16450         1   512B ChromeOS reserved
   /dev/sdc10   16451     16451         1   512B ChromeOS reserved
   /dev/sdc11      64     16447     16384     8M unknown
   /dev/sdc12  282624    413695    131072    64M EFI System

这里可以看到Chromium OS使用了12个分区，我们需要调整的是启动分区，也就是分区12 ``/dev/sdc12 ... EFI System``

调整Chromium OS config.txt
-----------------------------

参考 `Latest build (r72) still does not work with 7in touch screen#16 <https://github.com/FydeOS/chromium_os-raspberry_pi/issues/16>`_ 中方法，挂载分区12后修改 ``config.txt`` :

- 挂载第12分区EFI系统分区::

   mount /dev/sdc12 /mnt/


参考
======

- `FydeOS, a Tweaked Chromium OS for Chrome OS Fans, Hits the Raspberry Pi 400, Raspberry Pi 4 Range <https://www.hackster.io/news/fydeos-a-tweaked-chromium-os-for-chrome-os-fans-hits-the-raspberry-pi-400-raspberry-pi-4-range-13f678ed7882>`_
- `How to Install & Use Chromium OS on Raspberry Pi? (FydeOS) <https://raspberrytips.com/how-to-install-use-chromium-os-on-raspberry-pi-fydeos/>`_
- `GitHub - FydeOS / chromium_os-raspberry_pi <https://github.com/FydeOS/chromium_os-raspberry_pi>`_
