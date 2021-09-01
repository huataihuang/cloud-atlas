.. _wd_passport_ssd:

===============================
西部数据Passport SSD移动硬盘
===============================

为了解决 :ref:`pi_storage` 性能低下的短板，我尝试采用高速TF卡，但是发现性能依然无法和主流的Intel主机所配置的SSD磁盘性能相提并论。目前，可行的方式是通过树莓派USB 3.0接口连接SSD移动硬盘来提高存储性能。

我选择的是 西部数据my passport ssd固态移动硬盘，原因:

- 颜值高，非常小巧适合配合树莓派设备
- 虽然不是NvME固态硬盘，但是树莓派只有USB 3.0接口，最高只支持500MB/s，购买NvME的固态移动硬盘无法发挥性能。所以，这款SSD移动硬盘配合树莓派较好
- 价格相对较低

.. note::

   实际全盘连续写入测试，最高写入速度超过410MB/s，但是持续写入性能有波动，平均得到的性能大约260MB/s。我在考虑后续是不是可以采用NvME的固态硬盘，看看能否达到稳定的写入性能。

扇区之谜
============

我第三次购买的西数Passport SSD虽然 ``fdisk -l /dev/sda`` 显示有::

   Disk /dev/sda: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
   Disk model: ssport
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 4096 bytes / 33553920 bytes
   Disklabel type: dos
   Disk identifier: 0x221a87f7
   
   Device     Boot Start        End    Sectors   Size Id Type
   /dev/sda1        2048 1953521663 1953519616 931.5G  7 HPFS/NTFS/exFAT

但是我发现不管怎样使用 ``fdisk`` 创建分区，默认都只能从 ``65535`` 扇区开始::

   # fdisk /dev/sda
   
   Welcome to fdisk (util-linux 2.36.1).
   Changes will remain in memory only, until you decide to write them.
   Be careful before using the write command.
   
   
   Command (m for help): p
   Disk /dev/sda: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
   Disk model: ssport
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 4096 bytes / 33553920 bytes
   Disklabel type: dos
   Disk identifier: 0xcb6a7256
   
   Command (m for help): n
   Partition type
      p   primary (0 primary, 0 extended, 4 free)
      e   extended (container for logical partitions)
   Select (default p): p
   Partition number (1-4, default 1):
   First sector (65535-1953525167, default 65535):
   Last sector, +/-sectors or +/-size{K,M,G,T,P} (65535-1953525167, default 1953525167): +256MB
   
   Created a new partition 1 of type 'Linux' and of size 256 MiB.
   
   Command (m for help): p
   Disk /dev/sda: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
   Disk model: ssport
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 4096 bytes / 33553920 bytes
   Disklabel type: dos
   Disk identifier: 0xcb6a7256
   
   Device     Boot Start    End Sectors  Size Id Type
   /dev/sda1       65535 589814  524280  256M 83 Linux
   
   Partition 1 does not start on physical sector boundary.

可以看到分区开始位置并不是物理扇区边界 ``Partition 1 does not start on physical sector boundary.`` 


我注意到我前2次购买到 ``Disk model: My Passport 25F3`` 设备的 ``Sector size`` 和 ``I/O size (logical/physical)`` 和第3次购买的设备不同，原先是::

   Disk /dev/sda: 953.86 GiB, 1024175636480 bytes, 2000343040 sectors
   Disk model: My Passport 25F3
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 4096 bytes
   I/O size (minimum/optimal): 4096 bytes / 1048576 bytes
   Disklabel type: dos
   Disk identifier: 0xab86aefd
   
   Device     Boot  Start      End  Sectors  Size Id Type
   /dev/sda1  *      2048   526335   524288  256M  c W95 FAT32 (LBA)
   /dev/sda2       526336 67635199 67108864   32G 83 Linux

为什么第3次购买的设备::

   Disk model: ssport
   ...
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 4096 bytes / 33553920 bytes

而之前2次购买的设备sector不同::

   Disk model: My Passport 25F3
   ...
   Sector size (logical/physical): 512 bytes / 4096 bytes
   I/O size (minimum/optimal): 4096 bytes / 1048576 bytes

物理扇区从 ``4096`` 字节变成了 ``512`` 字节，而优化I/O大小从原先的 1MB (1048576/1024.0=1024.0) 更改成了约 32MB (33553920/1024.0/1024.0=31.99951171875)

`How to fix “Partition does not start on physical sector boundary” warning? <https://askubuntu.com/questions/156994/how-to-fix-partition-does-not-start-on-physical-sector-boundary-warning>`_ 提到了西部数据 `Advanced_Format <https://en.wikipedia.org/wiki/Advanced_Format>`_ 使用了4096字节的物理扇区取代陈旧的每个扇区512字节。并且西数还提供了一个 `Advanced Format Hard Drive Download Utility <https://web.archive.org/web/20150912110749/http://www.wdc.com/global/products/features/?id=7&language=1>`_ 介绍了在旧设备上启用Advanced Formatting提高性能。

西部数据提供了 `Western Digital Dashboard <https://support.wdc.com/downloads.aspx?lang=en&p=279>`_ 帮助用户分析磁盘(包括磁盘型号，容量，firmware版本和SMART属性)以及firmware更新

Western Digital Dashboard
============================

`Western Digital Dashboard <https://support.wdc.com/downloads.aspx?lang=en&p=279>`_ 提供了Windows版本，我部署使用 :ref:`alpine_extended` ，通过 :ref:`kvm` 运行Windows虚拟机来测试SSD磁盘，验证和排查为何最新购买的SSD磁盘使用了较小的物理扇区(512字节sector)


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

从测试时性能数据来看，SSD移动硬盘的写入IOPS确实非常高，能够达到 3w IOPS，并且带宽达到 120+MB/s

测试是性能显示::

   test_fio: Laying out IO file (1 file / 1024MiB)
   Jobs: 4 (f=4): [w(4)][100.0%][w=120MiB/s][w=30.7k IOPS][eta 00m:00s]
   test_fio: (groupid=0, jobs=4): err= 0: pid=2438: Wed Sep 23 23:05:51 2020
     write: IOPS=30.2k, BW=118MiB/s (124MB/s)(115GiB/1000001msec); 0 zone resets
       slat (usec): min=19, max=24485, avg=120.78, stdev=358.41
       clat (usec): min=26, max=95528, avg=4116.96, stdev=2997.23
        lat (usec): min=128, max=95733, avg=4238.47, stdev=3067.58
       clat percentiles (usec):
        |  1.00th=[ 1729],  5.00th=[ 1778], 10.00th=[ 2540], 20.00th=[ 2606],
        | 30.00th=[ 2638], 40.00th=[ 2999], 50.00th=[ 3392], 60.00th=[ 3785],
        | 70.00th=[ 4080], 80.00th=[ 4424], 90.00th=[ 5932], 95.00th=[10683],
        | 99.00th=[18482], 99.50th=[20841], 99.90th=[27395], 99.95th=[29492],
        | 99.99th=[36439]
      bw (  KiB/s): min=29136, max=165440, per=99.97%, avg=120660.79, stdev=9165.37, samples=7996
      iops        : min= 7284, max=41360, avg=30165.04, stdev=2291.35, samples=7996
     lat (usec)   : 50=0.01%, 100=0.01%, 250=0.01%, 500=0.01%, 750=0.01%
     lat (usec)   : 1000=0.01%
     lat (msec)   : 2=7.22%, 4=60.33%, 10=26.85%, 20=4.93%, 50=0.66%
     lat (msec)   : 100=0.01%
     cpu          : usr=5.79%, sys=79.52%, ctx=8968401, majf=0, minf=84
     IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
        submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
        complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
        issued rwts: total=0,30172855,0,0 short=0,0,0,0 dropped=0,0,0,0
        latency   : target=0, window=0, percentile=100.00%, depth=32
   Run status group 0 (all jobs):
     WRITE: bw=118MiB/s (124MB/s), 118MiB/s-118MiB/s (124MB/s-124MB/s), io=115GiB (124GB), run=1000001-1000001msec
   Disk stats (read/write):
     sda: ios=0/30170065, merge=0/8989, ticks=0/6428786, in_queue=35324, util=100.00%

测试时top显示::

   top - 22:50:28 up 7 min,  2 users,  load average: 3.89, 2.38, 1.00
   Tasks: 636 total,   6 running, 630 sleeping,   0 stopped,   0 zombie
   %Cpu0  :  3.0 us, 29.5 sy,  0.0 ni,  5.6 id,  0.0 wa,  0.0 hi, 62.0 si,  0.0 st
   %Cpu1  :  6.2 us, 89.3 sy,  0.0 ni,  4.5 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
   %Cpu2  :  5.9 us, 86.5 sy,  0.0 ni,  7.6 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
   %Cpu3  :  6.5 us, 87.3 sy,  0.0 ni,  6.2 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
   MiB Mem :   7811.3 total,   6976.8 free,    200.1 used,    634.4 buff/cache
   MiB Swap:      0.0 total,      0.0 free,      0.0 used.   7094.8 avail Mem
   
       PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
      2438 root      20   0  790132   4912    864 R  95.1   0.1   1:03.47 fio
      2441 root      20   0  790144   4932    880 R  92.5   0.1   1:02.84 fio
      2439 root      20   0  790136   4892    844 R  84.6   0.1   1:01.11 fio
      2440 root      20   0  790140   4928    876 R  75.5   0.1   0:58.63 fio
         9 root      20   0       0      0      0 R   5.6   0.0   0:04.06 ksoftirqd/0
         6 root       0 -20       0      0      0 I   2.0   0.0   0:03.66 kworker/0:0H-kblockd
      1894 root      20   0   11228   3676   2588 R   2.0   0.0   0:05.09 top
      2436 root      20   0  790140 428312 424288 S   1.6   5.4   0:02.75 fio
        10 root      20   0       0      0      0 I   0.3   0.0   0:00.21 rcu_preempt
      2156 root      20   0       0      0      0 I   0.3   0.0   0:00.73 kworker/0:12-events

.. note::

   测试时注意到 ``cpu0`` 的软中断极高，达到 62% ，说明存在瓶颈。而测试时，几乎没有 iowait ，显示SSD存储性能有余量未达到最高性能，树莓派的CPU瓶颈导致未能充分发挥SSD存储性能。 

.. note::

   在测试随机写IOPS时，我发现树莓派(2G版)突然重启，所以参考  :ref:`debug_system_crash` :ref:`debug_pi_fio_crash` 。详见排查文档。

   不过，最近购买的8G版本，并且升级内核之后，该项测试顺利通过。

- 对比测试SanDisk的128 TF卡(高速卡，官方参数达到90MB/s写入)，相同检测命令，获得4k写入性能： 2.7MB/s，659IOPS::

   test_fio: (g=0): rw=randwrite, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=32
   ...
   fio-3.16
   Starting 4 processes
   Jobs: 4 (f=4): [w(4)][6.4%][w=124KiB/s][w=31 IOPS][eta 24m:54s]
   test_fio: (groupid=0, jobs=4): err= 0: pid=2561: Wed Sep 23 23:18:33 2020
     write: IOPS=659, BW=2638KiB/s (2702kB/s)(261MiB/101377msec); 0 zone resets
       slat (usec): min=28, max=1584.7k, avg=748.82, stdev=16731.37
       clat (msec): min=2, max=5550, avg=193.21, stdev=276.96
        lat (msec): min=2, max=5550, avg=193.96, stdev=278.90
       clat percentiles (msec):
        |  1.00th=[    6],  5.00th=[   18], 10.00th=[   32], 20.00th=[   60],
        | 30.00th=[   88], 40.00th=[  118], 50.00th=[  148], 60.00th=[  178],
        | 70.00th=[  207], 80.00th=[  241], 90.00th=[  279], 95.00th=[  468],
        | 99.00th=[ 1720], 99.50th=[ 2165], 99.90th=[ 2970], 99.95th=[ 3272],
        | 99.99th=[ 4463]
      bw (  KiB/s): min=   32, max= 4162, per=100.00%, avg=2696.47, stdev=315.15, samples=792
      iops        : min=    8, max= 1040, avg=674.02, stdev=78.80, samples=792
     lat (msec)   : 4=0.36%, 10=1.97%, 20=3.57%, 50=10.65%, 100=17.58%
     lat (msec)   : 250=48.96%, 500=12.25%, 750=2.03%, 1000=0.72%, 2000=1.18%
     lat (msec)   : >=2000=0.74%
     cpu          : usr=0.34%, sys=1.64%, ctx=65062, majf=0, minf=83
     IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=99.8%, >=64=0.0%
        submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
        complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
        issued rwts: total=0,66869,0,0 short=0,0,0,0 dropped=0,0,0,0
        latency   : target=0, window=0, percentile=100.00%, depth=32
   
   Run status group 0 (all jobs):
     WRITE: bw=2638KiB/s (2702kB/s), 2638KiB/s-2638KiB/s (2702kB/s-2702kB/s), io=261MiB (274MB), run=101377-101377msec 

.. note::

   4k写入性能: SSD存储随机写4k性能是TF卡的 45.8 倍(IOPS)，接近46倍的差距。

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

测试结果显示写入带宽达到 320MB/s ， 2560 IOPS::

   test_serial_write: (g=0): rw=write, bs=(R) 128KiB-128KiB, (W) 128KiB-128KiB, (T) 128KiB-128KiB, ioengine=libaio, iodepth=128
   ...
   fio-3.16
   Starting 4 processes
   Jobs: 4 (f=4): [W(4)][100.0%][w=320MiB/s][w=2560 IOPS][eta 00m:00s]
   test_serial_write: (groupid=0, jobs=4): err= 0: pid=3194: Mon Sep 21 08:48:56 2020
     write: IOPS=2531, BW=316MiB/s (332MB/s)(309GiB/1000091msec); 0 zone resets
       slat (usec): min=43, max=97299, avg=1562.52, stdev=3709.91
       clat (msec): min=53, max=619, avg=200.67, stdev=20.54
        lat (msec): min=54, max=628, avg=202.24, stdev=20.57
       clat percentiles (msec):
        |  1.00th=[  146],  5.00th=[  163], 10.00th=[  184], 20.00th=[  192],
        | 30.00th=[  194], 40.00th=[  197], 50.00th=[  201], 60.00th=[  203],
        | 70.00th=[  205], 80.00th=[  209], 90.00th=[  218], 95.00th=[  241],
        | 99.00th=[  271], 99.50th=[  279], 99.90th=[  296], 99.95th=[  309],
        | 99.99th=[  334]
      bw (  KiB/s): min=244992, max=384574, per=99.97%, avg=323936.04, stdev=2701.86, samples=8000
      iops        : min= 1914, max= 3004, avg=2530.50, stdev=21.11, samples=8000
     lat (msec)   : 100=0.04%, 250=96.58%, 500=3.37%, 750=0.01%
     cpu          : usr=3.10%, sys=9.01%, ctx=572236, majf=0, minf=87
     IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%
        submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
        complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.1%
        issued rwts: total=0,2531704,0,0 short=0,0,0,0 dropped=0,0,0,0
        latency   : target=0, window=0, percentile=100.00%, depth=128
   
   Run status group 0 (all jobs):
     WRITE: bw=316MiB/s (332MB/s), 316MiB/s-316MiB/s (332MB/s-332MB/s), io=309GiB (332GB), run=1000091-1000091msec
   
   Disk stats (read/write):
     sda: ios=0/649953, merge=0/1877425, ticks=0/54335318, in_queue=53030424, util=100.00%

顺序读吞吐量（读带宽）
----------------------

- 顺序读吞吐量（读带宽）::

   fio -direct=1 -iodepth=128 -rw=read -ioengine=libaio \
   -bs=128k -numjobs=1 -time_based=1 -runtime=1000 \
   -group_reporting -filename=/mnt/fio.img -name=test_serial_read

测试结果显示顺序读带宽 379MB/s, 3032 IOPS，相对顺序写快20%::

   test_serial_read: (g=0): rw=read, bs=(R) 128KiB-128KiB, (W) 128KiB-128KiB, (T) 128KiB-128KiB, ioengine=libaio, iodepth=128
   fio-3.16
   Starting 1 process
   Jobs: 1 (f=1): [R(1)][100.0%][r=379MiB/s][r=3032 IOPS][eta 00m:00s]
   test_serial_read: (groupid=0, jobs=1): err= 0: pid=3749: Mon Sep 21 13:23:25 2020
     read: IOPS=3026, BW=378MiB/s (397MB/s)(369GiB/1000042msec)
       slat (usec): min=24, max=860, avg=53.87, stdev= 8.65
       clat (msec): min=7, max=519, avg=42.23, stdev=29.75
        lat (msec): min=7, max=519, avg=42.29, stdev=29.75
       clat percentiles (msec):
        |  1.00th=[   12],  5.00th=[   19], 10.00th=[   26], 20.00th=[   35],
        | 30.00th=[   42], 40.00th=[   43], 50.00th=[   43], 60.00th=[   43],
        | 70.00th=[   43], 80.00th=[   43], 90.00th=[   43], 95.00th=[   43],
        | 99.00th=[  218], 99.50th=[  296], 99.90th=[  342], 99.95th=[  359],
        | 99.99th=[  363]
      bw (  KiB/s): min=286720, max=388864, per=99.98%, avg=387312.22, stdev=2570.62, samples=2000
      iops        : min= 2240, max= 3038, avg=3025.77, stdev=20.10, samples=2000
     lat (msec)   : 10=0.37%, 20=5.87%, 50=90.67%, 100=0.97%, 250=1.37%
     lat (msec)   : 500=0.76%, 750=0.01%
     cpu          : usr=3.19%, sys=19.09%, ctx=759378, majf=0, minf=4122
     IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%
        submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
        complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.1%
        issued rwts: total=3026664,0,0,0 short=0,0,0,0 dropped=0,0,0,0
        latency   : target=0, window=0, percentile=100.00%, depth=128
   
   Run status group 0 (all jobs):
      READ: bw=378MiB/s (397MB/s), 378MiB/s-378MiB/s (397MB/s-397MB/s), io=369GiB (397GB), run=1000042-1000042msec
   
   Disk stats (read/write):
     sda: ios=756532/3, merge=2269603/1, ticks=31953025/280, in_queue=30273944, util=100.00%

参考
========

- `阿里云帮助文档: 测试块存储性能 <https://help.aliyun.com/document_detail/147897.html>`_
