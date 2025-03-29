.. _cpuidle:

============================================
CPU空闲时间管理(CPU Idle Time Management)
============================================

CPUIdle governors
=====================

有4种 ``CPUIdle`` governors:

- menu
- TEO
- ladder
- haltpoll

通过内核命令行控制Idle状态
============================

除了影响CPU空闲时间管理的架构级(architecture-level)内核命令选项外，还有一些参数可以通过内核命令行传递来影响单个 ``CPUIdle`` 驱动。

具体而言:

- ``intel_idle.max_cstate=<n>`` 和 ``processor.max_cstate=<n>`` 参数，其中 ``<n>`` 是空闲状态索引，也用于 ``sysfs`` 中给定状态的目录名称
- ``intel_idle.max_cstate=<n>`` 和 ``processor.max_cstate=<n>`` 参数会让 ``intel_idle`` 和 ``acpi_idle`` 驱动程序分别丢弃被指定空闲状态 ``<n>`` 更深的所有空闲状态:

  - 上述 ``max_cstate`` 是idle驱动的最深空闲状态值
  - 当 ``max_cstate=0`` 时，``intel_idle`` 和 ``acpi_idle`` 驱动程序的行为是不同的 **敲黑板了** 我在 :ref:`debug_lscpu_slow` 就遇到 :ref:`amd_cpu_c-state_freezing` 缺陷

    - ``intel_idle.max_cstate=0`` 会禁用 ``intel_idle`` 驱动并允许使用 ``acpi_idle``
    - 然而 ``processor.max_cstate=0`` 等同于 ``processor.max_cstate=1``
    - ``acpi_idle`` 驱动是单独加载的内核模块的一部分，当该内核模块加载时， ``max_cstate=<n>`` 会传递给内核模块

参考
======

- `CPU Idle Time Management <https://docs.kernel.org/admin-guide/pm/cpuidle.html>`_
