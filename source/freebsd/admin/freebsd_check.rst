.. _freebsd_check:

====================
FreeBSD检查方法
====================

在FreeBSD平台，如果需要执行硬件驱动安装，如 :ref:`freebsd_nvidia-driver` 或者 :ref:`freebsd_wifi` 我们首先需要确认硬件品牌和型号。在Linux平台，我们通常会使用 ``lspci`` 和 ``dmidecode`` 这样的检测命令，那么FreeBSD平台是否有对应的工具呢？

检查架构平台以及release
========================

- 和 Linux 不同， ``unmae -r`` 并没有显示running的内核版本，而是显示release版本::

   $ uname -r
   13.1-RELEASE-p2

- 显示硬件平台类型(machine) 使用参数 ``-m`` ::

   $ uname -m
   amd64

- 显示主机名 ``-n`` ::

   $ uname -n
   liberty-dev

- 显示relase的version level 使用参数 ``-v`` ::

   $ uname -v
   FreeBSD 13.1-RELEASE-p2 GENERIC

- 同时显示上述所有参数的输出使用 ``-a`` ::

   $ uname -a
   FreeBSD liberty-dev 13.1-RELEASE-p2 FreeBSD 13.1-RELEASE-p2 GENERIC amd64

处理器信息
============

获取处理器信息一种方式是使用dmesg信息::

   $ dmesg | grep CPU
   CPU: Intel(R) Core(TM) i7-4850HQ CPU @ 2.30GHz (2294.80-MHz K8-class CPU)

另一种方式是使用 ``sysctl`` ::

   sysctl -a hw.model

显示输出::

   hw.model: Intel(R) Core(TM) i7-4850HQ CPU @ 2.30GHz

此外，获取内存信息也是使用 ``sysctl`` ::

   sysctl -a | grep mem

输出信息非常详尽，例如::

   ...
   vfs.tmpfs.memory_reserved: 4194304
   vfs.zfs.unflushed_max_mem_ppm: 1000
   vfs.zfs.unflushed_max_mem_amt: 1073741824
   ...
   hw.physmem: 17040584704
   hw.usermem: 16160497664
   hw.realmem: 17179869184
   hw.pci.host_mem_start: 2147483648
   hw.cbb.start_memory: 2281701376
   ...

你都可以通过指定 ``sysctl -a hw.physmem`` 这样的命令一一对应提取

综合上述方法，可以使用 ``egrep`` 一次性提取所需的信息，例如:

.. literalinclude:: freebsd_check/sysctl_cpu_mem
   :caption: 通过 ``sysctl`` 获取硬件信息

可以看到我的组装机 :ref:`nasse_c246` 安装的 :ref:`xeon_e-2274g` 以及 64G 内存:

.. literalinclude:: freebsd_check/sysctl_cpu_mem_output
   :caption: 通过 ``sysctl`` 获取硬件信息



内存查看工具
========================

在Linux平台有很多观察内存使用的工具，已经被很多运维人员熟知。FreeBSD也移植了这些工具:

- :ref:`htop` 提供了详尽的系统观察方法
- ``freecolor`` 相当于 Linux 的 ``free`` 命令::

   pkg install freecolor

使用方法::

   freecolor -t -m -o

输出类似::

                total       used       free     shared    buffers     cached
   Mem:         15781        685      15095          0          0          0
   Swap:         2048          0       2048
   Total:       17829 = (     685 (used) +    17143 (free)) 

- 检查swap使用情况使用 ``swapinfo`` 工具::

   swapinfo -m

输出类似::

   Device          1M-blocks     Used    Avail Capacity
   /dev/nvd0p3          2048        0     2048     0%

观察负载
=========

- 和Linux类似，使用 ``uptime`` ::

   uptime

输出类似::

    7:03AM  up  3:15, 2 users, load averages: 0.07, 0.04, 0.00

- 检查系统最近一次重启::

   last -1 reboot

输出类似::

   boot time                                  Sun Oct  9 03:48

- 检查最近一次关机::

   last -1 shutdown

输出类似::

   utx.log begins Fri Oct  7 08:09:05 CST 2022

检查用户登陆
=============

- 检查当前谁登陆在系统中::

   w

输出类似::

    7:13AM  up  3:24, 2 users, load averages: 0.00, 0.01, 0.00
   USER       TTY      FROM            LOGIN@  IDLE WHAT
   huatai     v8       :0              3:49AM  3:24 -
   huatai     pts/4    192.168.6.200   6:39AM     - w 

- 检查当前登陆人::

   who

输出类似::

   huatai           ttyv8        Oct  9 03:49 (:0)
   huatai           pts/4        Oct  9 06:39 (192.168.6.200)

- 用户::

   users

输出::

   huatai

- 检查指定用户登陆情况，例如这里检查 ``huatai`` ::

   last huatai

输出类似::

   huatai     pts/5    l-v1l5lvdl-1304.stagin Sun Oct  9 06:48 - 06:49  (00:00)
   huatai     pts/4    192.168.6.200          Sun Oct  9 06:39   still logged in
   huatai     ttyv8    :0                     Sun Oct  9 03:49   still logged in
   huatai     :0                              Sun Oct  9 03:49   still logged in
   huatai     ttyv8    :0                     Sun Oct  9 03:44 - shutdown  (00:04)
   huatai     :0                              Sun Oct  9 03:44 - shutdown  (00:04)
   huatai     ttyv8    :0                     Sun Oct  9 02:08 - 03:43  (01:35)
   huatai     :0                              Sun Oct  9 02:08 - 03:43  (01:35)
   ...

硬件检查
=========

pciconf
---------

在 Linux 中常用的 ``lspci`` ，在FreeBSD中有对应的 ``pciconf`` ::

   pciconf -lv

输出类似::

   ...
   vgapci0@pci0:1:0:0:	class=0x030000 rev=0xa1 hdr=0x00 vendor=0x10de device=0x0fe9 subvendor=0x106b subdevice=0x0130
       vendor     = 'NVIDIA Corporation'
       device     = 'GK107M [GeForce GT 750M Mac Edition]'
       class      = display
       subclass   = VGA
   hdac0@pci0:1:0:1:	class=0x040300 rev=0xa1 hdr=0x00 vendor=0x10de device=0x0e1b subvendor=0x106b subdevice=0x0130
       vendor     = 'NVIDIA Corporation'
       device     = 'GK107 HDMI Audio Controller'
       class      = multimedia
       subclass   = HDA
   none1@pci0:3:0:0:	class=0x028000 rev=0x03 hdr=0x00 vendor=0x14e4 device=0x43a0 subvendor=0x106b subdevice=0x0134
       vendor     = 'Broadcom Inc. and subsidiaries'
       device     = 'BCM4360 802.11ac Wireless Network Adapter'
       class      = network 
   ...

.. note::

   也可以安装 ``pciutils`` 来获得和Linux平台一样的 ``lspci`` 命令

.. _dmidecode:

dmidecode
------------

FreeBSD也提供了和Linux相同的 ``dmidecode`` ::

   pkg install dmidecode

``dmidecode``  使用案例::

   dmidecode

- 检查处理器::

   dmidecode -t processor

输出信息非常详细

- 检查内存::

   dmidecode -t memory

- 检查bios::

   dmidecode -t bios

注意，所有检查类型也可以用数字代替，例如检查 bios 可以用代码0::

   dmidecode -t 0

以下是dmidecode的代码列表:

.. csv-table:: dmidecode检测代码列表
   :file: freebsd_check/dmidecode.csv
   :widths: 10, 90
   :header-rows: 1   

参考
======

- `FreeBSD Display Information About The System Hardware <https://www.cyberciti.biz/tips/freebsd-display-information-about-the-system.html>`_
- `FreeBSD CPU Information Command <https://www.cyberciti.biz/faq/howto-find-out-freebsd-cpuinfo/>`_
