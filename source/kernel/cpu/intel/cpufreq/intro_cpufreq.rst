.. _intro_cpufreq:

=====================
CPU性能伸缩技术概述
=====================

`CPU performance scaling <https://docs.kernel.org/admin-guide/pm/cpufreq.html>`_ 能够让操作系统按需调整CPU 频率来节约电能或者提高性能。CPU频率伸缩性可以按照系统负载自动响应，针对ACPI 事件调整，或者使用用户空间程序手工调整。

CPU Frequency的推荐接口: ``sysfs``
====================================

在Linux系统中，建议和CPU Frequency交互的接口使用 ``sysfs`` 系统。在挂载的 ``/sys`` 文件系统中， 位于cpu设备目录下的 ``cpufreq`` 子目录就是内核交互接口。这个接口是按照cpu核心来分布目录结构的，例如 ``/sys/devices/system/cpu/cpu0/cpufreq/`` 就是第一个CPU，目录下有以下访问接口:

.. csv-table:: cpufreq 访问接口文件
   :file: intro_cpufreq/sys_cpufreq.csv
   :widths: 20, 80
   :header-rows: 1



参考
=======

- `The Linux kernel user’s and administrator’s guide » Power Management » Working-State Power Management » CPU Performance Scaling <https://www.kernel.org/doc/html/v4.14/admin-guide/pm/cpufreq.html>`_
- `Debian wiki: CpuFrequencyScaling <https://wiki.debian.org/CpuFrequencyScaling>`_
- `arch linux: CPU frequency scaling <https://wiki.archlinux.org/title/CPU_frequency_scaling>`_
- `CPU Frequency utility <https://wiki.analog.com/resources/tools-software/linuxdsp/docs/linux-kernel-and-drivers/cpufreq/cpufreq>`_
