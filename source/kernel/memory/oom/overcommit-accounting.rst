.. _overcommit-accounting:

=====================================
过度使用记账(Overcommit Accounting)
=====================================

overcommit handing modes
==========================

Linux内核支持以下 ``overcommit`` 处理模式:

- ``0`` : **启发式** ``overcommit`` 

``启发式过度分配`` 拒绝明显的地址空间过度使用，用于典型系统(默认配置)。这种处理模式可以确保严重的疯狂分配(seriously wild allocation)失败，同时允许(适当) ``overcommit`` 以减少swap空间使用。这个模式也允许 ``root`` 用户分配更多的内存。

- ``1`` : **始终** ``overcommit`` 

``始终过度分配`` 适合一些科学应用。典型的案例是使用稀疏矩阵(sparse arrays)的代码，并且仅依赖完全由 ``零页面`` (zero pages)组成的虚拟内存

- ``2`` : **禁止** ``overcommit``

``禁止过度分配`` 设置下，系统的总地址空间提交(total address space commit)不允许超过 ``swap + (物理内存*overcommit_ratio)`` 的可配置数量( ``overcommit_ratio`` 默认是 ``50%`` )。根据内存使用量，大多数情况下进程在访问页面时不会被终止，但是会在恰当的时候收到内存分配错误

检查和设置 ``overcommit`` 处理模式
-----------------------------------

``sysctl`` 检查 ``vm.overcommit_memory`` 设置值:

.. literalinclude:: overcommit-accounting/sysctl_overcommit_memory
   :language: bash
   :caption: ``sysctl`` 检查 ``vm.overcommit_memory`` 设置值

通常情况下，该值是 ``0`` (启发式过度分配):

.. literalinclude:: overcommit-accounting/sysctl_overcommit_memory_output
   :language: bash
   :caption: ``vm.overcommit_memory`` 设置值通常为0

直接检查 ``/proc/sys`` 下的配置也可以查看该配置:

.. literalinclude:: overcommit-accounting/procfs_sys_vm.overcommit_memory
   :language: bash
   :caption: 检查procfs中 ``vm.overcommit_memory`` 设置

配合 ``overcommit`` 配置值 ``2`` 的两个参数
---------------------------------------------

当 ``vm.overcommit_memory`` 设置为 ``2`` (也就是禁止过度分配)时，此时有两个配套参数(仅在 ``vm.overcommit_memory = 2`` 时生效):

- ``vm.overcommit_ratio`` 过度分配百分比，也就是 ``swap + RAM`` 的百分比允许过度分配
- ``vm.overcommit_kbytes`` 过度分配绝对值

上述两个配套参数入口也位于 ``/proc/sys/vm`` 下::

   # ls /proc/sys/vm/overcommit*
   /proc/sys/vm/overcommit_kbytes  /proc/sys/vm/overcommit_memory  /proc/sys/vm/overcommit_ratio

这两个值默认不生效( 因为系统默认 ``vm.overcommit_memory = 0`` )::

   # sysctl vm.overcommit_kbytes
   vm.overcommit_kbytes = 0

   # sysctl vm.overcommit_ratio
   vm.overcommit_ratio = 50

当前 ``overcomit``
----------------------

当前系统的过度使用限制(overcommit limit)和提交量(ammount commmited)可以通过 ``/proc/meminfo`` 的 ``CommitLimit`` 和 ``Committed_AS`` 查看

案例:

- 检查Linux系统内存分配:

.. literalinclude:: overcommit-accounting/meminfo
   :language: bash
   :caption: 检查 /proc/meminfo

输出信息:

.. literalinclude:: overcommit-accounting/meminfo_output
   :language: bash
   :caption: cat /proc/meminfo 输出信息
   :emphasize-lines: 1,31,32

可以看到 ``MemTotal`` 表示主机实际安装内存大小（192G）; 内存过度使用当前限制大约是 94.4GB ，而当前过度分配提交量是 50.3GB

验证
------

.. literalinclude:: overcommit-accounting/vm.overcommit_memory
   :language: bash
   :caption: 调整 ``vm.overcommit_memory``

参考
========

- `Overcommit Accounting <https://docs.kernel.org/mm/overcommit-accounting.html>`_
- `Out-of-memory (OOM) in Kubernetes – Part 2: The OOM killer and application runtime implications <https://mihai-albert.com/2022/02/13/out-of-memory-oom-in-kubernetes-part-2-the-oom-killer-and-application-runtime-implications/>`_
