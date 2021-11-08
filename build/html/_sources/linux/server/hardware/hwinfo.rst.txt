.. _hwinfo:

==================================
Linux系统硬件信息检测工具hwinfo
==================================

我们在排查系统问题时，很多时候需要确认服务器硬件信息。我发现 ``hwinfo`` 工具能够提供有序组织的硬件系统，对于问题排查，以及为客户提供运维服务时采集需要排查问题的服务器信息非常有用。

``hwinfo`` 使用 ``libhd.so`` 系统库来搜集所有硬件的详细信息，例如BIOS, CPU, 架构, 内存, 硬盘, 分区, 摄像头, 蓝牙, CD/DVD, 键盘鼠标, 图形卡, 显示器, Modem, 扫描仪, 打印机, PCI, IDE, SCSI, 声卡, 网卡, USB 等等...

安装
=======

- Fedoa::

   sudo dnf install hwinfo

- CentOS(需要激活EPEL)::

   sudo dnf install epel-release
   sudo yum install hwinfo

- debian/ubuntu::

   sudo apt install hwinfo

- openSUSE::

   sudo zypper install hwinfo

使用
========

- 可以不使用任何参数来使用 ``hwinfo`` 命令::

   sudo hwinfo

或者::

   sudo hwinfo --all

输出信息类似如下::

   ...
     Processor Info: #3
       Socket: "Proc 1"
       Socket Type: 0x2b (Other)
       Socket Status: Populated
       Type: 0x03 (CPU)
       Family: 0xb3 (Xeon)
       Manufacturer: "Intel(R) Corporation"
       Version: "Intel(R) Xeon(R) CPU E5-2670 v3 @ 2.30GHz"
       Asset Tag: "UNKNOWN"
       Processor ID: 0xbfebfbff000306f2
       Status: 0x01 (Enabled)
       Voltage: 1.6 V
       External Clock: 100 MHz
       Max. Speed: 4000 MHz
       Current Speed: 2300 MHz
       L2 Cache: #1
       L3 Cache: #2
   ...

上述硬件信息输出非常繁多，有可能过于庞杂，所以也有一个简单输出方式，使用参数 ``--short`` ::

   sudo hwinfo --short

输出类似::

   cpu:                                                            
                          Intel(R) Xeon(R) CPU E5-2670 v3 @ 2.30GHz, 1200 MHz
                          Intel(R) Xeon(R) CPU E5-2670 v3 @ 2.30GHz, 1200 MHz
   ...

使用hwinfo显示特定设备信息
---------------------------

- 检查CPU的相信信息::

   sudo hwinfo --cpu

显示输出非常详细的CPU规格:

.. literalinclude:: hwinfo/hwinfo_cpu.txt
   :language: bash

- 同样也有简略输出CPU信息参数 ``--short`` ::

   sudo hwinfo --short --cpu

输出类似::

   cpu:
                          Intel(R) Xeon(R) CPU E5-2670 v3 @ 2.30GHz, 1200 MHz
                          ...

使用hwinfo显示系统架构
------------------------

- 系统架构::

   sudo hwinfo --arch

显示输出::

   Arch: X86_64/grub

使用hwinfo显示内存详情
--------------------------

- 内存信息详情::

   sudo hwinfo --memory

输出:

.. literalinclude:: hwinfo/hwinfo_disk.txt
   :language: bash

使用hwinfo显示分区详情
----------------------------

- 可以显示硬盘的分区详情::

   sudo hwinfo --partition

输出信息:

.. literalinclude:: hwinfo/hwinfo_partition.txt
   :language: bash

使用hwinfo显示网卡详情
------------------------

- 显示网卡的详情::

   sudo hwinfo --network

输出信息:

.. literalinclude:: hwinfo/hwinfo_network.txt
   :language: bash

使用hwinfo显示BIOS详情
--------------------------

- 显示BIOS详情::

   sudo hwinfo --bios

输出信息:

.. literalinclude:: hwinfo/hwinfo_bios.txt
   :language: bash

.. note::

   ``hwinfo`` 可以侦测所有其他硬件内容

输出硬件信息到文件
====================

``hwinfo`` 可以用来输出完整的系统硬件报告，也可以记录到文件中用于进一步排查和分析::

   sudo hwinfo --all --log hardwareinfo.txt

或者::

   sudo hwinfo --all > hardwareinfo.txt

参考
=========

- `Find Linux System Hardware Information With Hwinfo <https://ostechnix.com/find-linux-system-hardware-information-with-hwinfo/>`_
