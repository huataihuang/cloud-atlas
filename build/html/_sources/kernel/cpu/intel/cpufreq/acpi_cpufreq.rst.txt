.. _acpi_cpufreq:

====================
ACPI cpufreq
====================

我在排查 :ref:`debug_lscpu_slow` 发现国产化海光服务器启用了 ``acpi_cpufreq`` 内核模块之后，似乎出现了比较大性能问题:

- ``cpupower`` 配置了 ``performance`` governor
- 当使用 ``acpi-cpufreq`` 驱动时，处理器的主频被限制在 ``1.20 GHz - 2.00 GHz`` ，可能无法达到硬件实际最高主频 ``2.40 GHz``

- 当出现CPU ``sys`` 压力时，会阻塞 ``lscpu`` 运行可能和 :ref:`cpuidle` 缺陷有关

那么为何我升级内核(修订内核参数)的早期海光服务器会加载 ``acpi_cpufreq`` 内核模块进而启动了 ``acpi-cpufreq`` 驱动的 :ref:`cpufreq` 功能呢?

而公司

参考
=======

- `How to use ACPI CPUfreq driver in Red Hat Enterprise Linux 7 ? <https://access.redhat.com/solutions/253803>`_
