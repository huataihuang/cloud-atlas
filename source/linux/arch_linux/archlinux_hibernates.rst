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

在内核的 ``/sys/power/state`` 接口写入相应字符串可以触发suspend。在内核文档中 `states.txt <https://www.kernel.org/doc/Documentation/power/states.txt>`_ 有详细说明。

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

可以调整 ``/sys/power/image_size`` 大小，可以尽可能缩小这个swap大小，也可以增加这个swap大小来加速hibernate处理速度。注意，suspend镜像不能跨多个swap分区或者多个swap文件，必须完全存储在一个swap分区或者一个swap文件。

需要的内核参数
~~~~~~~~~~~~~~~~~

需要使用内核参数 ``resume=swap_device`` ，这里的 ``swap_device`` 是持久化块设备命名，例如::

   resume=UUID=4209c845-f495-4c43-8a03-5363dd433153
   resume="PARTLABEL=Swap partition"
   resume=/dev/archVolumeGroup/archLogicalVolume  (如果是LVM逻辑卷)

Hibernation到swap文件
========================

.. note::

   内核5.0之前不支持Btrfs文件系统的swap文件，如果在Btrfs文件系统中使用swap文件存储hibernetes会导致文件系统损坏。虽然能够在Btrfs中将swap文件挂载成一个loop设备，但是这样会显著降低swap性能。

使用swap文件爱你需要传递给内核参数 ``resume_offset=swap_file_offset`` 。

.. note::

   ``resume`` 参数必须指向 swap文件所在的卷。对于堆叠类型的块设备，例如加密容器，或者RAID，或者LVM，这意味着 ``resume`` 必须指向包含swap文件的文件系统的 ``unlocked`` 或者 ``mapped`` 设备。

通过 ``filefreg -v swap_file`` 可以获得 ``swap_file_offset`` 值，输出内容的第一行中 ``phyiscal_offset`` 列值就是需要提供的定位值::

   filefrag -v /swapfile

输出内容::

   Filesystem type is: ef53
   File size of /swapfile is 4294967296 (1048576 blocks of 4096 bytes)
    ext:     logical_offset:        physical_offset: length:   expected: flags:
      0:        0..       0:      38912..     38912:      1:            
      1:        1..   22527:      38913..     61439:  22527:             unwritten
      2:    22528..   53247:     899072..    929791:  30720:      61440: unwritten   

上述输出中第一行的 ``physical_offset`` 列，即 ``38912`` 就是我们查询得到的偏移值。

.. note::

   如果安装了 ``uswsusp`` 工具包，则提供了一个 ``swap-offset`` 命令可以直接输出swap问价的偏移值::

      swap-offset swap_file

Hibernate设置实践
=====================

- 获取swap文件应该设置的大小::

   /sys/power/image_size

例如，输出值是 ``6672080896`` 则对应大约 6.4GB

- 创建swap文件::

   dd if=/dev/zero of=/swap bs=64MiB count=100

- 创建swap::

   mkswap /swap
   swapon /swap

- 配置 ``/etc/fstab`` 添加swap配置::

   /swap none swap defaults 0 0

- 获取磁盘分区uuid::

   blkid /dev/sda3

输出显示::

   /dev/sda3: UUID="e38d80cc-4044-4d34-b730-1f0c874ad765" TYPE="ext4" PARTLABEL="arch_linux" PARTUUID="c31f68cd-97f7-4471-93c7-adb62b22a17b"


- 获取 ``/swap`` 文件偏移量::

   filefrag -v /swap

输出::

   Filesystem type is: ef53
   File size of /swap is 6710886400 (1638400 blocks of 4096 bytes)
    ext:     logical_offset:        physical_offset: length:   expected: flags:
      0:        0..   32767:    7798784..   7831551:  32768:
   ...

则偏移量是: ``7798784``

- 需要向内核传递参数::

   resume=UUID=e38d80cc-4044-4d34-b730-1f0c874ad765
   swap_file_offset=7798784

.. note::

   我在MacBook Pro上使用的EFI设置启动是采用 ``efibootmgr`` ，请参考 :ref:`archlinux_on_mbp` ，所以，这里需要通过 ``efibootmgr`` 传递内核参数。

将原先设置efibootmgr命令::

   efibootmgr --disk /dev/sda --part 1 --create --label "Arch Linux" --loader /vmlinuz-linux --unicode 'root=PARTUUID=c31f68cd-97f7-4471-93c7-adb62b22a17b rw initrd=\initramfs-linux.img' --verbose

添加上hibernate参数如下::

   efibootmgr --disk /dev/sda --part 1 --create --label "Arch Linux" --loader /vmlinuz-linux --unicode 'root=PARTUUID=c31f68cd-97f7-4471-93c7-adb62b22a17b rw initrd=\initramfs-linux.img resume=UUID=e38d80cc-4044-4d34-b730-1f0c874ad765 swap_file_offset=7798784' --verbose

- 重启操作系统

参考
=====

- `Power management/Suspend and hibernate <https://wiki.archlinux.org/index.php/Power_management/Suspend_and_hibernate>`_
