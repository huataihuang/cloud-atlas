.. _clone_jetson_system:

================
克隆Jetson系统
================

在 :ref:`backup_restore_jetson` 我介绍了如何通过tar工具备份和恢复一个Ubuntu系统(Jetson)，这种方法是比较常规的Linux备份恢复方案。不过，由于需要调整磁盘UUID以及重建GRUB，所以操作比较繁琐且有一定难度。

其实还有一种非常简单粗暴的备份和恢复操作系统的方法：通过 ``dd`` 命令完整克隆系统。这种方法是块设备的 ``bit`` 复制，所以完全不需要了解上层文件系统的结构和内容，只需要保证目标磁盘设备的空间大于源设备就可以实现。


使用 ``dd`` 方式clone系统虽然具有和系统无关简单便利的特性，理论上总是能够成功。但是，这种方式需要 ``bit-to-bit`` 完整读取整个源磁盘，所以存在以下不足：

- 必须完整读取磁盘，对于只使用了部分磁盘空间的系统复制效率很低
- 无法选择只备份必要数据，造成存储资源浪费
- 目标磁盘必须大于源盘，硬件上有限制

备份和恢复TF卡
==============

clone的目标存储卡容量必须大于源存储卡容量，否则会导致复制失败。

- 如果有两个存储卡可以直接接在同一台电脑上，则可以使用 ``dd`` 命令直接复制

- 这里我只有一个TF转接卡，所以我先把原先的Jetson Nano的TF卡复制成压缩打包文件::

   sudo dd if=/dev/rdisk2 conv=sync,noerror bs=100m | gzip -c > ~/jetson_image.img.gz

.. note::

   这里的 ``dd`` 命令是在 macOS上执行，所以和Linux参数上略有差异。

- 打包成功以后，换成新的目标TF卡，再执行以下命令恢复备份::

   gunzip -c ~/jetson_image.img.gz | sudo dd of=/dev/rdisk2 bs=100m

完成恢复之后，使用新的TF卡启动Jetson Nano，验证是否成功。

磁盘分区修复
==============

使用上述 ``dd`` 方式复制得到的TF卡实际使用空间和之前的源TF卡一样，因为完全是 ``bit-to-bit`` 复制。此时用 ``fdisk -l`` 查看，会有一行提示::

   GPT PMBR size mismatch (61497343 != 249737215) will be corrected by w(rite).

以下则是当前磁盘分区，显示仅使用了大约30G空间::

   Disk /dev/mmcblk0: 119.1 GiB, 127865454592 bytes, 249737216 sectors
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: gpt
   Disk identifier: 43CAB209-E630-440C-8D77-5A7C6BD76C49

   Device          Start      End  Sectors  Size Type
   /dev/mmcblk0p1  28672 61495295 61466624 29.3G Linux filesystem
   /dev/mmcblk0p2   2048     2303      256  128K Linux filesystem
   /dev/mmcblk0p3   4096     4991      896  448K Linux filesystem
   /dev/mmcblk0p4   6144     7295     1152  576K Linux filesystem
   /dev/mmcblk0p5   8192     8319      128   64K Linux filesystem
   /dev/mmcblk0p6  10240    10623      384  192K Linux filesystem
   /dev/mmcblk0p7  12288    13055      768  384K Linux filesystem
   /dev/mmcblk0p8  14336    14463      128   64K Linux filesystem
   /dev/mmcblk0p9  16384    17279      896  448K Linux filesystem
   /dev/mmcblk0p10 18432    19327      896  448K Linux filesystem
   /dev/mmcblk0p11 20480    22015     1536  768K Linux filesystem
   /dev/mmcblk0p12 22528    22655      128   64K Linux filesystem
   /dev/mmcblk0p13 24576    24735      160   80K Linux filesystem
   /dev/mmcblk0p14 26624    26879      256  128K Linux filesystem

   Partition table entries are not in disk order.

我们需要修正GPT分区，并且将磁盘剩余空间使用起来。

- 使用 ``parted`` 工具修正分区::

   parted -a optimal /dev/mmcblk0

显示::

   GNU Parted 3.2
   Using /dev/mmcblk0
   Welcome to GNU Parted! Type 'help' to view a list of commands.
   (parted) print
   Warning: Not all of the space available to /dev/mmcblk0 appears to be used,
   you can fix the GPT to use all of the space (an extra 188239872 blocks) or
   continue with the current setting?
   Fix/Ignore?

这里答复: ``Fix``

然后提示信息::

   Model: SD SN128 (sd/mmc)
   Disk /dev/mmcblk0: 128GB
   Sector size (logical/physical): 512B/512B
   Partition Table: gpt
   Disk Flags:
   
   Number  Start   End     Size    File system  Name     Flags
    2      1049kB  1180kB  131kB                TBC
    3      2097kB  2556kB  459kB                RP1
    4      3146kB  3736kB  590kB                EBT
    5      4194kB  4260kB  65.5kB               WB0
    6      5243kB  5439kB  197kB                BPF
    7      6291kB  6685kB  393kB                BPF-DTB
    8      7340kB  7406kB  65.5kB               FX
    9      8389kB  8847kB  459kB                TOS
   10      9437kB  9896kB  459kB                DTB
   11      10.5MB  11.3MB  786kB                LNX
   12      11.5MB  11.6MB  65.5kB               EKS
   13      12.6MB  12.7MB  81.9kB               BMP
   14      13.6MB  13.8MB  131kB                RP4
    1      14.7MB  31.5GB  31.5GB  ext4         APP

- 此时分区表已经被 ``parted`` 修复，所以，我们只需要输入 ``quit`` 命令退出程序。然后再次执行 ``parted -a optimal /dev/mmcblk0`` 就不再提示错误信息。并且使用 ``fdisk -l`` 也不再提示错误。

.. note::

   我不知道为何Jetson创建了很多几百K的分区，而实际 ``/`` 根文件系统仅使用 ``/dev/mmcblk0p1`` 一个分区。这个以后再探索一下。

   我准备采用外接的SSD移动硬盘作为Jetson Nano的存储，这样可以大幅度提升存储性能。相关测试实践我另外撰写。



参考
=====

- `Clone SD Card – Jetson Nano and Xavier NX <https://www.jetsonhacks.com/2020/08/08/clone-sd-card-jetson-nano-and-xavier-nx/>`_
