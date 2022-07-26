.. _acpi_cpufreq:

====================
ACPI cpufreq
====================

我在排查 :ref:`debug_lscpu_slow` 发现国产化海光服务器启用了 ``acpi_cpufreq`` 内核模块之后，似乎出现了比较大性能问题:

- ``cpupower`` 配置了 ``performance`` governor
- 当使用 ``acpi-cpufreq`` 驱动时，处理器的主频被限制在 ``1.20 GHz - 2.00 GHz`` ，可能无法达到硬件实际最高主频 ``2.40 GHz``

- 当出现CPU ``sys`` 压力时，会阻塞 ``lscpu`` 运行可能和 :ref:`cpuidle` 缺陷有关

那么为何我升级内核(修订内核参数)的早期海光服务器会加载 ``acpi_cpufreq`` 内核模块进而启动了 ``acpi-cpufreq`` 驱动的 :ref:`cpufreq` 功能呢?

原因就在于:

BIOS/UEFI 配置Power Management策略
====================================

在现代服务器的 BIOS/UEFI 配置中，有关电源管理选项决定了主机是否采用 ``OS`` 控制电源管理模式:

- 例如 :ref:`hpe_dl360_gen9` 服务器，在 ``System configuration ---> Bios ---> Power Management`` 配置中，有一个 ``Power Profile`` 配置项，当选择 ``OS Control Mode``

.. figure:: ../../../../_static/kernel/cpu/intel/cpufreq/power_management_os_control_mode.png
   :scale: 80

- 并且内核参数配置了 ``intel_pstate=disable`` ，则系统启动时就会尝试加载 ``acpi_cpufreq`` 内核模块

.. note::

   我的实践发现，如果 **没有** 配置 ``intel_pstate`` 选项，只要BIOS激活 ``OS Control Mode`` 的电源管理策略，也会自动加载 ``acpi_cpufreq`` 

.. note::

   如果BIOS已经激活 ``OS Control Mode`` 电源管理策略，但是要禁用 ``acpi_cpufreq`` ，就需要把 ``acpi_cpufreq`` 内核模块加入黑名单避免加载。详见 :ref:`debug_lscpu_slow`

参考
=======

- `How to use ACPI CPUfreq driver in Red Hat Enterprise Linux 7 ? <https://access.redhat.com/solutions/253803>`_
