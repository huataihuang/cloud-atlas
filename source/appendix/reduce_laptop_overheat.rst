.. _reduce_laptop_overheat:

=====================
降低笔记本温度过热
=====================

在使用MacBook Pro笔记本电脑 :ref:`introduce_my_studio` ，如果发现笔记本电脑的风扇持续高速运行，并且笔记本非常热，可以采用本文介绍的一些技术来降低系统温度。

.. note::

   `Linux 4.20 Fixing Bug Where Plugging In A MacBook Pro Leads To Excessive CPU Usage <https://phoronix.com/scan.php?page=news_item&px=Linux-MBP-Power-Change-CPU-Use>`_ 说明上游内核4.20或5.0修复了一个插入或拔出最新款苹果MacBook Pro笔记本电源将导致CPU资源过渡消耗问题。此外，最新的MacBook Pro笔记本不能开箱即用，主要存在无限问题，以及没有主线内核的Touch Bar驱动等，所以当前对于2018年版本MacBook笔记本，Linux尚不能很好支持。

对于运行在笔记本尚的Linux，需要考虑采用一些手段来防止笔记本过热引发的问题，包括控制CPU温度，监控硬件温度。

安装防止笔记本过热的工具
===========================

TLP
-----

`TLP <https://linrunner.de/en/tlp/tlp.html>`_ 是一个Linux电源管理工具，这是一个预先配置的防止过热的服务，可以延长电池寿命。TLP默认已经配置了电池优化，所以只需要简单安装就可以生效，不需要特别配置。

::

   sudo add-apt-repository ppa:linrunner/tlp
   sudo apt-get update
   sudo apt-get install tlp tlp-rdw

如果使用ThinkPad，还需要附加步骤::

   sudo apt-get install tp-smapi-dkms acpi-call-dkms

然后重启系统

.. note::

   `TLP Linux Advanced Power Management <https://linrunner.de/en/tlp/docs/tlp-linux-advanced-power-management.html>`_ 详细介绍了TLP工作原理和配置，

禁用Thunderbolt
===================

Linux的电源管理管理对于Mac的Thunderbolt卡支持不好，这样Thunderbolt始终工作并阻止CPU进入节电状态，即使在不使用时也会消耗2W电力。

- 修改 ``/etc/default/grub`` 设置::

   GRUB_CMDLINE_LINUX="ipv6.disable=1 acpi_osi=!Darwin"

- 执行更新grub::

     sudo update-grub

.. note::

   我测试下来似乎禁用TB adapter有效，当然也可能和启用TLP有关。

Intel Linux Thermal Daemon
=============================

`Intel开源的Linux* Thermal Daemon <https://01.org/linux-thermal-daemon/documentation/introduction-thermal-daemon>`_ 提供了对台式机和笔记本系统的高性能环境下结合P-states, T-states 以及Intel power clamp驱动来实现的节能。

- 激活 ``intel_pstate`` （这个激活可能在高版本Ubuntu中不需要，因为实践发现，即使没有在内核显式激活，进入系统依然可以发现已经采用了 ``intel_pstate`` ，不过，我这里依然采用明确激活。即编辑 ``/etc/default/grub`` 添加::

   GRUB_CMDLINE_LINUX="ipv6.disable=1 acpi_osi=!Darwin intel_pstate=enable"

然后执行 ``sudo update-grub``

- 安装 cpupower 工具::

   sudo apt-get install linux-tools-common linux-tools-generic

- 执行 ``cpupower frequency-info`` 检查确认已经具备了 ``driver: intel_pstate``

- 重启系统后检查默认的电源管理策略::

   cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

显示应该是::

   powersave

如果不是powersave，可以通过如下命令设置powersave策略::

   sudo cpupower frequency-set -g performance

如果不想节能，而是要追求最佳性能，也可以设置性能最佳策略::

   sudo cpupower frequency-set -g performance

- 安装themald::

   sudo apt install thermald

.. note::

   实际发现系统已经安装了 ``thermald`` ，而且已经运行。如果是TLP之前安装的，则说明对系统降低温度最有效的是TLP。

温度监控
===========

对于服务器硬件的监控，底层是采用 `lm-sensors <https://github.com/lm-sensors/lm-sensors>`_ 提供了对硬件监控驱动的支持。

- 安装::

   sudo apt install lm-sensors

- 安装以后，需要执行一次 ``sensors-detect`` 指令，以便能够检测出系统的硬件::

   sudo sensors-detect

注意：最后会提示是否将检测到驱动添加到 ``/etc/modules`` ，如果你满意自动检测结果，则回答 ``yes`` ，否则需要手工编辑配置文件。

.. note::

   我计划参考 `Lm-sensors or other way to monitor cpu, board temperatures <https://forums.balena.io/t/lm-sensors-or-other-way-to-monitor-cpu-board-temperatures/4173>`_ 提供的线索，采用 `Netdata <https://github.com/netdata/netdata>`_ 或者 `telegraf <https://github.com/influxdata/telegraf>`_ 实现完整的硬件监控解决方案。

参考
==========

- `Most Effective Ways To Reduce Laptop Overheating In Linux <https://itsfoss.com/reduce-overheating-laptops-linux/>`_
- `Prevent Your Laptop From Overheating With Thermald And Intel P-State <http://www.webupd8.org/2014/04/prevent-your-laptop-from-overheating.html>`_
- `SensorInstallHowto <https://help.ubuntu.com/community/SensorInstallHowto>`_
