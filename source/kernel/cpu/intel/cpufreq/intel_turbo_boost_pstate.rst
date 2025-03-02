.. _intel_turbo_boost_pstate:

====================================
Intel Turbo Boost技术和intel_pstate
====================================

Intel Turbo Boost
=================

**Intel Turbo Boost** 是Intel在Xeon系列处理器实现的技术，通过动态控制处理器的时钟率来激活处理器运行在超过基础操作主频。

支持不同Turbo Boost版本技术的处理器分为：

-  Turbo Boost 1.0: Nehalem
-  Turbo Boost 2.0: Sandby Bridge
-  Turbo Boost Max 3.0: Ivy Bridge, Haswell, Broadwell, Skylake, Broadwell-E

Turo Boost是在操作系统请求处理器的最高性能状态（highest performance state, pstate）时候激活。

处理器性能状态是通过高级配置和电源接口（Advanced Configuration and Power Interface, ACPI）规范来定义的，这是被所有主流操作系统所支持的开放标准。在Turbo Boost背后的设计概念也被称为 ``动态超频`` 。

时钟主频是由处理器电压，电流和热量所限制的，同时也受到当前CPU核心数量和激活核心的最高主频限制。当处理器上负载调用更快性能，并且此时处理器还没有达到上限，则处理器时钟将增加操作频率以满足需求。频率增长，在Nehalem处理器是133MHz，而在Sand Bridge, Ivy Bridge，Haswell和Skylake处理器是100MHz。

Intel Turbo Boost监控处理器当期使用情况，以及处理器是否接近最大 ``热量设计功率`` （thermal design power, TDP）。这个TDP是处理器支持的最大功率。

配置实践
===========

服务器BIOS
-------------

操作系统内核
--------------

- 修改 ``/etc/default/grub`` 配置行 ``GRUB_CMDLINE_LINUX`` 添加::

   GRUB_CMDLINE_LINUX_DEFAULT="... intel_pstate=enable processor.max_cstate=1 intel_idle.max_cstate=1"

- 更新grub::

   sudo update-grub

- 使用 :ref:`kexec` 快速切换内核::

   kexec -l /boot/vmlinuz-5.4.0-126-generic --initrd=/boot/initrd.img-5.4.0-126-generic
   systemctl kexec

- 重启系统后，执行 :ref:`cpu_frequency_governor` 切换::

   cpupower frequency-set -g performance

.. note::

   我最终还是放弃了 ``performacne`` ，原因是默认高性能运行会导致 :ref:`hpe_dl360_gen9` 的散热风扇高速运转，噪音无法忍受。而使用 ``powersave`` 则非常安静，所以最终日常还是使用 ``powersave`` governor。

参考
=======

