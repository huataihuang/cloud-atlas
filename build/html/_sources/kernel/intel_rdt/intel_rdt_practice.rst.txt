.. _intel_rdt_practice:

====================
Intel RDT实践
====================

我们在 :ref:`intel_rdt_arch` 对Intel RDT架构有了初步了解，本文会通过一些实际案例分析和实践来帮助理解理论知识。

在Linux上激活Intel RDT资源管理
===============================

Linux 4.10以上版本内核支持Intel RDT技术，基础架构是基于 ``resctrl`` 文件系统来实现的，提供了一个用户接口。通常系统管理员就是通过这个 ``resctrl`` 用户接口来分配资源，也就是调用内核来配置QoS MSRs以及tasks或CPUs的CLOSIDs。当一个CPU调度任务运行时，这个任务的CLOSID就被加载到PQR MSR作为上下文切换。当任务运行时，通过CLOSID索引当CBM就会指定这个任务能够分配的缓存以及通过一个CLOSID索引的指定延迟值来分配内存带宽。

resctrl文件系统
====================

内核参数 ``CONFIG_INTEL_RDT_A`` 激活RDT支持，并且需要有处理器的 ``/proc/cpuinfo`` 中flag： ``rdt`` , ``cat_l3`` 和 ``cdp_l3``

- 请先 ``cat /proc/cpuinfo`` 查看处理器是否支持上述开关参数::

   cat /proc/cpuinfo | grep flags

例如，在 ``Intel Xeon Platinum 8163 CPU`` 处理器可以看到支持参数 ``rdt_a`` 和 ``cdp_l3``

- 使用以下命令挂载文件系统和支持功能::

   mount -t resctrl resctrl [-o cdp] /sys/fs/resctrl

参考
=======

- `RESOURCE ALLOCATION IN INTEL® RESOURCE DIRECTOR TECHNOLOGY <https://01.org/intel-rdt-linux/blogs/fyu1/2017/resource-allocation-intel%C2%AE-resource-director-technology>`_
