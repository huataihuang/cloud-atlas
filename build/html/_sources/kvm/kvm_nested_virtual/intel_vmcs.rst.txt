.. _intel_vmcs:

===============
Intel VMCS
===============

Intel Virtual Machine Control Structure (Intel VMCS) shadowing ，即 Intel虚拟机控制结构映射，是Intel 自2013年推出Haswell系列志强处理器提供的 :ref:`hardware_virtual` 技术中重要的改进。

.. note::

   知乎上「河马虚拟化」专栏有一篇 `VMX(2) -- VMCS理解 <https://zhuanlan.zhihu.com/p/49257842>`_ 详细描述了VMCS结构和切换的逻辑。

响应灵敏和安全的桌面虚拟化需要使用虚拟机监控(virtualization machine monitor, VMM)软件来部署和管理虚拟机，以及底层硬件平台。第4代Intel Core vPro处理器提供了新型代基于硬件的Virtual Machine Control Structure (VMCS) Shadowing技术，可以实现多重VMM使用模式的高性能加速。

.. image:: ../../_static/kvm/kvm_nested_virtual/nested_virtualization.png
   :scale: 50

VMCS改进
==========

- VMCS通过硬件层加速减少了L0层VM退出

.. image:: ../../_static/kvm/kvm_nested_virtual/software_and_hardware_vmcs.png
   :scale: 50



参考
=========

- `4th Generation Intel Core vPro Processors with Intel VMCS Shadowing <https://www.intel.com/content/dam/www/public/us/en/documents/white-papers/intel-vmcs-shadowing-paper.pdf>`_
- `The Turtles Project: Design and Implementation of Nested Virtualization <https://www.usenix.org/legacy/events/osdi10/tech/full_papers/Ben-Yehuda.pdf>`_
- `Nested Virtualization — KVM, Intel, with VMCS Shadowing <https://kashyapc.wordpress.com/2013/05/16/nested-virtualization-kvm-intel-with-vmcs-shadowing/>`_
