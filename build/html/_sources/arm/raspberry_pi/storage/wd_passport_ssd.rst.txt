.. _wd_passport_ssd:

===============================
西部数据Passport SSD移动硬盘
===============================

为了解决 :ref:`pi_storage` 性能低下的短板，我尝试采用高速TF卡，但是发现性能依然无法和主流的Intel主机所配置的SSD磁盘性能相提并论。目前，可行的方式是通过树莓派USB 3.0接口连接SSD移动硬盘来提高存储性能。

我选择的是 西部数据my passport ssd固态移动硬盘，原因:

- 颜值高，非常小巧适合配合树莓派设备
- 虽然不是NvME固态硬盘，但是树莓派只有USB 3.0接口，最高只支持500MB/s，购买NvME的固态移动硬盘无法发挥性能。所以，这款SSD移动硬盘配合树莓派较好
- 价格相对较低

文件系统格式化
==============

为初步测试性能，并对比TF卡性能，采用先划分 128G 磁盘空间::

   # parted -a optimal /dev/sda
   GNU Parted 3.3
   Using /dev/sda
   Welcome to GNU Parted! Type 'help' to view a list of commands.
   (parted) print
   Model: WD My Passport 25F3 (scsi)
   Disk /dev/sda: 1024GB
   Sector size (logical/physical): 512B/4096B
   Partition Table: gpt
   Disk Flags:

   Number  Start   End     Size    File system  Name         Flags
    1      1049kB  1024GB  1024GB               My Passport  msftdata

    (parted) rm 1
    (parted) print
    Model: WD My Passport 25F3 (scsi)
    Disk /dev/sda: 1024GB
    Sector size (logical/physical): 512B/4096B
    Partition Table: gpt
    Disk Flags:

    Number  Start  End  Size  File system  Name  Flags

    (parted) mkpart primary ext4 0 128G
    Warning: The resulting partition is not properly aligned for best performance:
    34s % 2048s != 0s
    Ignore/Cancel? c
    (parted) mkpart primary ext4 2048s 128G
    (parted) align-check optimal 1
    1 aligned
    (parted) quit
    Information: You may need to update /etc/fstab.

- 文件系统格式化::

   mkfs.ext4 /dev/sda1

- 挂载磁盘::

   mount /dev/sda1 /mnt

性能测试
=========

随机写IOPS
-------------

- 随机写IOPS::

   fio -direct=1 -iodepth=32 -rw=randwrite -ioengine=libaio -bs=4k \
   -numjobs=4 -time_based=1 -runtime=1000 -group_reporting \
   -filename=fio.img -size=1g -name=test_fio

从测试时性能数据来看，SSD移动硬盘的写入IOPS确实非常高，能够达到 3w IOPS，并且带宽达到 100+MB/s（最高有150MB/s，并且有4w IOPS）。

.. note::

   在测试随机写IOPS时，我发现树莓派突然重启，所以参考  :ref:`debug_system_crash` :ref:`debug_pi_fio_crash` 。详见排查文档。

随机读IOPS
-------------

顺序写吞吐量(写带宽)
-----------------------

- 测试命令::

   fio -direct=1 -iodepth=128 -rw=write -ioengine=libaio \
   -bs=128k -numjobs=4 -time_based=1 -runtime=1000 \
   -group_reporting -filename=/mnt/fio.img -name=test

顺序写入性能达到 319MB/s ，2550 IOPS ，比较稳定。另外，测试发现，并发 ``--jobs`` 是1还是4，实际获得的总带宽基本相同。不过，并发4个jobs，则系统load较高(load>=4)，所以负载还是比单个jobs要大很多，总体来看这块SSD的顺序读写能力稳定。

top显示::

   top - 08:39:01 up  8:33,  4 users,  load average: 4.13, 3.13, 1.51
   Tasks: 151 total,   1 running, 150 sleeping,   0 stopped,   0 zombie
   %Cpu0  :  4.6 us, 18.1 sy,  0.0 ni, 66.0 id, 10.6 wa,  0.0 hi,  0.7 si,  0.0 st
   %Cpu1  :  4.9 us,  9.8 sy,  0.0 ni, 70.9 id, 14.4 wa,  0.0 hi,  0.0 si,  0.0 st
   %Cpu2  :  3.3 us, 10.5 sy,  0.0 ni, 74.0 id, 12.2 wa,  0.0 hi,  0.0 si,  0.0 st
   %Cpu3  :  2.6 us, 10.5 sy,  0.0 ni, 75.0 id, 11.8 wa,  0.0 hi,  0.0 si,  0.0 st
   MiB Mem :   1848.2 total,    759.8 free,    263.3 used,    825.2 buff/cache
   MiB Swap:      0.0 total,      0.0 free,      0.0 used.   1148.3 avail Mem
   
       PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
      3196 root      20   0  806544  21300    888 D  12.6   1.1   0:49.07 fio
      3197 root      20   0  806548  21312    900 D  12.3   1.1   0:49.08 fio
      3194 root      20   0  806536  21308    888 D  11.9   1.1   0:49.01 fio
      3195 root      20   0  806540  21308    888 D  11.9   1.1   0:49.00 fio
      3208 root       0 -20       0      0      0 I   8.9   0.0   0:06.89 kworker/0:0H-kblockd
      3192 root      20   0  790140 428580 424560 S   1.3  22.6   0:06.18 fio
      3162 root      20   0   10684   3008   2592 R   0.7   0.2   0:04.11 top

顺序写入没有出现异常重启现象。

顺序读吞吐量（读带宽）
----------------------

- 顺序读吞吐量（读带宽）::

   fio -direct=1 -iodepth=128 -rw=read -ioengine=libaio \
   -bs=128k -numjobs=1 -time_based=1 -runtime=1000 \
   -group_reporting -filename=/mnt/fio.img -name=test

参考
========

- `阿里云帮助文档: 测试块存储性能 <https://help.aliyun.com/document_detail/147897.html>`_
