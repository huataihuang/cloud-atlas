.. _linux_system_time:

=======================
Linux系统时间
=======================

.. note::

   在 :ref:`arch_linux` 安装后，发现系统时间是UTC时间，和本地时间差8小时。所以整理一下系统时间设置方法

在操作系统中，时间(时钟)是由3部分确定:

- 时间值
- 本地时间还是UTC或者其他时区
- 是否使用夏令时(DST)

大多数操作系统的标准做法是:

- 操作系统启动时根据硬件时钟设置系统时钟
- 保持系统时钟准确(通过 :ref:`ntp` )
- 关机时从根据系统时钟设置硬件时钟

硬件时钟
==========

- 查看硬件时钟::

   hwclock --show

例如显示输出::

   2022-11-10 14:57:34.941004+00:00

根据系统时钟设置硬件时钟
-------------------------

可以根据系统时钟来矫正硬件时钟，此时会更新 ``/etc/adjtime`` ::

   hwclock --systohc

系统时钟
===============

系统时钟(system clock)也称为软件时钟(software clock)，保持跟踪: 时间，时区以及夏令时。这个系统时钟通过内核来计算从1970年1月1日午夜开始的秒数。这个系统时钟初始化时候时从硬件时钟开始的，然后根据 ``/etc/adjtime`` 。当启动完成，系统时钟的运行就不依赖于硬件间时钟了，内核会通过计算计时器中断(timer interrupts)来保持系统时钟准确。

读取系统时钟
---------------

- 检查系统时钟::

   timedatectl

显示输出::

                  Local time: Thu 2022-11-10 15:20:13 UTC
              Universal time: Thu 2022-11-10 15:20:13 UTC
                    RTC time: Thu 2022-11-10 15:20:13
                   Time zone: n/a (UTC, +0000)
   System clock synchronized: no
                 NTP service: inactive
             RTC in local TZ: no

- 可以使用 ``timedatectl`` 命令手工设置时间::

   timedatectl set-time "yyyy-MM-dd hh:mm:ss"

时间标准
=============

有两种时间标准：本地时间和协调世界时 (UTC)。本地时间标准取决于当前时区，而 UTC 是全球时间标准，与时区值无关。

硬件时钟（CMOS时钟，BIOS时间）使用的标准是由操作系统设定的。默认情况下，Windows 使用本地时间，macOS 使用 UTC，如果一台机器上安装了多个操作系统，它们都会从同一个硬件时钟中获取当前时间：建议将其设置为 UTC 以避免跨系统冲突。

.. note::

   这次我是在 MacBook Pro上安装 :ref:`arch_linux` ，笔记本之前安装的是macOS，然后抹除重新安装Linux

时区
=======

- 检查可用时区::

   timedatectl list-timezones

这里可以找到上海的时区: ``Asia/Shanghai``

- 设置时区::

   timedatectl set-timezone Asia/Shanghai

设置完成后，就可以看到现在显示的是上海本地时间，而不是之前的UTC时间了(使用 ``date`` 命令)::

   Thu Nov 10 23:28:41 CST 2022

此时可以看到 ``/etc/localtime`` 被链接到时区文件::

   lrwxrwxrwx 1 root root 35 Nov 10 23:28 /etc/localtime -> ../usr/share/zoneinfo/Asia/Shanghai

时钟同步
============

应该 :ref:`deploy_ntp` 来保障网络时钟同步，建议采用 :ref:`chrony` ，通过 :ref:`sync_time_by_chrony` 。

参考
=====

- `arch linux: System time <https://wiki.archlinux.org/title/System_time>`_
