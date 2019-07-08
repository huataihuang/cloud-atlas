.. _ipmitool_tips:

===================
IPMI工具ipmitool
===================

.. note::

   在我的运维工作生涯中，感觉服务器串口通讯控制台真是远程运维的利器。不论是Sun小型机、NetAPP存储设备、Cisco路由器，还是数据中心的PC服务器，在设置好串口控制台之后，都能在远程维护设备，即使设备操作系统异常也没有影响。

   IPMI是 ``Intelligent Platform Management Interface`` ，提供了管理和监控服务器的方法，在Linux平台，通过 ``ipmitool`` 可以运维服务器，是你日常工作必不可少的工具。

本文摘要了一些我认为对SA非常有用的ipmitool案例，也是我个人自备的手册。

重启MC控制器
===============

BMC难免存在BUG，有时候作为带外管理设备，自身也会死机。

- 如果能够登录操作系统，可以在操作系统执行命令冷重启BMC恢复::

   modprobe ipmi-devintf
   modprobe ipmi-si
   ipmitool mc reset cold

.. warning::

   在系统级别变更后重启操作系统前，一定要确保带外能够正确访问终端，否则一旦OS故障没有带外访问，就只有机房现场操作了，对于故障抢修等紧急情况，几乎是不可接受的情况。所以重启操作系统之前，务必检查带外管理。切记，切记，这是有血的教训的！！！
   
   日常监控中，需要将带外访问作为监控项目，并及时处理带外访问异常的故障，避免留下隐患。
   
   如果带外异常，建议在操作系统中执行一次 ``mc reset cold`` ，大多数情况能够修复带外访问。

- 如果不能登陆操作系统，但是带外还能够响应指令，可以尝试远程重启BMC::

     ipmitool -I lanplus -H IP -U username -P password mc reset cold

远程访问终端
==============

::

   ipmitool -I lanplus -H IP  -U username -P password -E sol activate

重启服务器
=============

::

   ipmitool -I lanplus -H IP -U username -P password power reset

检查服务器sol日志（故障原因）
==============================

::

   ipmitool sel list

设置启动设备
==============

设置服务器从PXE重启
---------------------

::

   ipmitool raw 0x00 0x08 0x05 0x80 0x04 0x00 0x00 0x00

   # 推荐临时启动PXE
   ipmitool chassis bootdev pxe
   ipmitool chassis bootparam set bootflag force_pxe

设置强制启动进入BIOS设置
---------------------------

::

   ipmitool raw 0x00 0x08 0x05 0x80 0x18 0x00 0x00 0x00
   ipmitool chassis bootdev bios
   ipmitool chassis bootparam set bootflag force_bios

从默认的硬盘启动
-------------------

::

   ipmitool raw 0x00 0x08 0x05 0x80 0x08 0x00 0x00 0x00
   ipmitool chassis bootdev disk
   ipmitool chassis bootparam set bootflag force_disk

从CD/DVD启动
--------------

::

   ipmitool raw 0x00 0x08 0x05 0x80 0x14 0x00 0x00 0x00
   ipmitool chassis bootdev cdrom
   ipmitool chassis bootparam set bootflag force_cdrom

获取系统启动选项
-------------------

- 获取系统启动选项 - ``NetFn = Chassis (0x00h), CMD = 0x09h`` ::

   ipmitool raw 0x00 0x09 Data[1:3]

例如::

   ipmitool raw 0x00 0x09 0x05 0x00 0x00

输出::

   01 05 80 18 00 00 00
   Where,
   Response Data[5]
   0x00: No override
   0x04: Force PXE
   0x08: Force boot from default Hard-drive
   0x14: Force boot from default CD/DVD
   0x18: Force boot into BIOS setup

参考
=====

- `IPMI-Chassis Device <https://github.com/erik-smit/oohhh-what-does-this-ipmi-doooo-no-deedee-nooooo/blob/master/1-discovering/snippets/Computercheese/IPMI-Chassis%20Device%20Commands.txt>`_
    
