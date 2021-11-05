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



参考
=========

- `Find Linux System Hardware Information With Hwinfo <https://ostechnix.com/find-linux-system-hardware-information-with-hwinfo/>`_
