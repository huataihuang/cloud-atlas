.. _amd_cpu_c-state:

=======================
AMD CPU c-state
=======================

.. _amd_cpu_c-state_freezing:

ADM Ryzon处理器随机"冻结"问题
=================================

AMD Ryzon处理器似乎在 ``c-states`` 电源管理上存在缺陷，可能会在低负载时随机"冻结"。这个问题绕过低方法是在内核参数添加::

   processor.max_cstate=1

此外，一些系统中内核可以覆盖BIOS设置(见 :ref:`acpi_cpufreq` BIOS有一种设置 ``Power Regulator = OS Control Mode`` 表示操作系统可以决定电源管理 )，此时就需要再加上一个 ``intel_idle.max_cstate=0`` 来确保不进入睡眠状态。否则执行 ``cat /sys/module/intel_idle/parameters/max_cstate`` 会看到数值是 ``9`` ，这样就存在逻辑上冲突(感觉AMD这块有BUG)

所以，我实际配置:

.. literalinclude:: amd_cpu_c-state/disable_cstate
   :language: bash
   :caption: 关闭AMD的cstate避免"冻结"问题

重启服务器后检查::

   $cat /sys/module/intel_idle/parameters/max_cstate
   0

也即是(对于intel处理)强制不进入 :ref:`cpu_c-state` 的节能状态，这个措施对于配置了允许OS控制BIOS的电源管理(见 :ref:`acpi_cpufreq` )是有效的，实践验证，对这种BIOS配置的AMD处理器也需要这样处理。

.. note::

   上述问题我是在国产化海光处理器上发现，该处理器是 :ref:`amd_zen` 微架构，应该也存在这样的缺陷。最好的解决方案可能还是在BIOS中关闭Power Manager，这样就不会出现上述冲突。

参考
========

- `What are the CPU c-states? How to check and monitor the CPU c-state usage in Linux per CPU and core? <https://www.golinuxhub.com/2018/06/what-cpu-c-states-check-cpu-core-linux/>`_
- `wmealing/C-states.md <https://gist.github.com/wmealing/2dd2b543c4d3cff6cab7>`_
- `Random "Freezing" with AMD Ryzen CPUs <https://gist.github.com/dlqqq/876d74d030f80dc899fc58a244b72df0>`_
