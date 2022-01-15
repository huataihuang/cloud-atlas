.. _pi_clock:

=================
树莓派时钟
=================

我在 :ref:`alpine_install_pi` 遇到 :ref:`alpine_pi_clock_skew` 困扰，导致重启系统后无法挂载文件系统。

树莓派物理硬件上采用了非常小的成本，省略了常规计算机中使用的硬件时钟( ``hardware clock`` , RTC, Real Time Clock, CMOS clock, BIOS clock )。硬件时钟是主板上通过电池维持的时钟，即使主机关闭也能够保证时间。在操作系统中，有一个系统时间( ``system clock`` )
，这个时钟在操作系统启动时通过硬件时钟来设置，操作系统启动以后就用系统时钟来跟踪时间。当操作系统关闭时，会使用系统时间来设置硬件时钟，以便记录重启之间的时间。Linux使用 ``clocksource`` 来维护时间，大多数情况下都以来硬件。

但是对于虚拟机，以及 :ref:`raspberry_pi` 都没有硬件时钟(设备)，对于树莓派，比较简单都方法是在GPIO接口上加一个硬件时钟硬件

.. figure:: ../../../_static/linux/alpine_linux/ds3231-rtc-module-for-raspberry-pi.jpg
   :scale: 50

时钟精度
==========

时钟精度是使用 ``ppm`` (parts per million)，表示每百万偏差，例如 3ppm 表示 每100万 有3个偏差，所以: ``3/10e6 x 24 x 60 x 60 = 0.2592 sec/day`` 表示每天有 ``0.2592秒`` 偏差，累积下来一年最大约 ``95秒`` 偏差。对于原子钟精度可以达到 ``0.0000001 ppm``

Linux时钟
===========

由于硬件时钟只在系统启动时使用，所以操作系统运行时不使用硬件时钟来维护时间。内核维护使用 ``clocksource`` 有多种硬件来源。在x86硬件环境，最常用都时钟源是 ``TSC`` (Time Stamp Counter), ``acpi_pm`` 和 ``HPET`` (High Precision Event Timer):

- 检查当前时钟源::

   cat /sys/devices/system/clocksource/clocksource0/current_clocksource

可以看到::

   tsc

- 可用时钟源::

   cat /sys/devices/system/clocksource/clocksource0/available_clocksource

输出通常是::

   tsc hpet acpi_pm

树莓派时钟源
=============

树莓派没有集成 ``TSC`` 或 ``HPET counter`` ，而是依赖 ``STC`` 作为时钟源，所谓 ``STC`` 是一个按照 ``1MHz`` 频率运行的计数器，也就是每毫米为单位增量。

我对比了 :ref:`ubuntu64bit_pi` 以及初始安装的 Alipine Linux for Raspberry Pi(无盘模式，能够启动)，发现都是使用 ``arch_sys_counter`` 作为时钟源::

   cat /sys/devices/system/clocksource/clocksource0/current_clocksource

显示::

   arch_sys_counter

但是，实际上出现 :ref:`alpine_pi_clock_skew` 也同样使用了 ``arch_sys_counter`` 作为时钟源，为何会出现 ``clock skew`` 报错呢？

树莓派系统使用 ``adjtimex`` 来维护时间，在 ``/etc/default/adjtimex`` 中配置::

   TICK=10000
   FREQ=0

然后重新启动::

   /etc/init.d/adjtimex restart

参考
=========

- `How accurately can the Raspberry Pi keep time? <https://blog.remibergsma.com/2013/05/12/how-accurately-can-the-raspberry-pi-keep-time/>`_
