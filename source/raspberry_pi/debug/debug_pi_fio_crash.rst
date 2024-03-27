.. _debug_pi_fio_crash:

=======================================
排查Raspberry Pi 4存储测试fio出现crash
=======================================

- 随机写IOPS::

   fio -direct=1 -iodepth=32 -rw=randwrite -ioengine=libaio -bs=4k \
   -numjobs=4 -time_based=1 -runtime=1000 -group_reporting \
   -filename=fio.img -size=1g -name=test_fio

从测试时性能数据来看，SSD移动硬盘的写入IOPS确实非常高，能够达到 3w IOPS，并且带宽达到 100+MB/s（最高有150MB/s，并且有4w IOPS）。

但是，测试不到一分钟，树莓派突然重启。

重启时系统似乎hang在SYS上，没有任何 iowait ::

   top - 23:46:54 up 20 min,  2 users,  load average: 2.45, 0.67, 0.23
   Tasks: 144 total,   5 running, 139 sleeping,   0 stopped,   0 zombie
   %Cpu0  :  3.2 us, 23.7 sy,  0.0 ni,  7.3 id,  0.0 wa,  0.0 hi, 65.8 si,  0.0 st
   %Cpu1  :  7.9 us, 88.4 sy,  0.0 ni,  3.6 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
   %Cpu2  :  7.9 us, 90.5 sy,  0.0 ni,  1.6 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
   %Cpu3  :  8.3 us, 89.0 sy,  0.0 ni,  2.7 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
   MiB Mem :   1848.2 total,    951.3 free,    180.9 used,    716.1 buff/cache
   MiB Swap:      0.0 total,      0.0 free,      0.0 used.   1230.8 avail Mem

       PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
      1918 root      20   0  790140   5020    976 R  93.0   0.3   0:28.70 fio
      1916 root      20   0  790132   4980    936 R  87.4   0.3   0:28.58 fio
      1917 root      20   0  790136   4992    948 R  87.4   0.3   0:28.63 fio
      1919 root      20   0  790144   5052   1008 R  86.8   0.3   0:28.27 fio
         9 root      20   0       0      0      0 S   5.6   0.0   0:01.81 ksoftirqd/0
      1921 root       0 -20       0      0      0 I   3.0   0.0   0:10.73 kworker/0:0H-kblockd
      1914 root      20   0  790140 428532 424512 S   2.0  22.6   0:02.03 fio
      1913 root      20   0   10684   3124   2712 R   0.7   0.2   0:00.28 top

我怀疑是内核bug，high sys可能和内核锁有关
