.. _intro_bhyve:

======================
bhyve简介
======================

FreeBSD的高性能 :ref:`hypervisor` 名为 ``bhyve`` ，类似于Linux内核的 :ref:`kvm` hypervisor，可以创建和运行虚拟机，性能接近于裸机速度。

``bhybe`` 采用BSD license，从FreeBSD 10.0-RELEASE开始就是base系统的一部分，支持不同的guests系统，包括FreeBSD,OpenBSD, :ref:`linux` 和 :ref:`windows` 。默认是， ``bhyve`` 提供了一个串口控制台但是不会模拟图形控制台。对于新型CPU提供的虚拟化卸
载(virtualization offload)可以避免传统的指令转换和人工管理内存映射。

``bhyve`` 硬件要求
===================

- 支持 :ref:`intel_ept` 的 :ref:`intel_cpu`
- 支持 AMD Rapid Virtualization Indexing(RVI)或Nested Page Table(NPT)的 :ref:`amd_cpu`
- 支持 ``Stage-2`` MMU 虚拟化扩展的 ARM ``aarch64`` (例如ARMv8)

注意，FreeBSD的 ``bhyve`` 在ARM上只支持纯ARMv8.0虚拟化，目前尚未使用虚拟化主机扩展(Virtualization Host Extensions)。托管具有多个vCPU的Linux guest或FreeBSD guest需要VMX非限制模式支持(UG)。

最简单判断Intel或AMD处理器是否支持 ``bhyve`` 的简单方法是运行 ``dmesg`` 或在 ``/var/run/dmesg.boot`` 中查找AMD处理器 ``Features2`` 行上的 ``POPCNT`` 处理器功能标志，或者Intel处理器 :ref:`intel_vt` 行上的EPT和UG

.. literalinclude:: intro_bhyve/dmesg_popcnt_ept_ug
   :caption: 检查CPU对POPCNT和EPT和UG支持

例如，我组装了一台 :ref:`xeon_e-2274g` 台式机用来不停机(静音)运行，检查 ``dmesg`` 输出:

.. literalinclude:: intro_bhyve/dmesg_vt
   :caption: 使用 ``dmesg`` 检查CPU是否支持SLAT( :ref:`intel_ept` )
   :emphasize-lines: 12

参考
======

- `FreeBSD handbook: Chapter 24. Virtualization <https://docs.freebsd.org/en/books/handbook/virtualization/>`_
