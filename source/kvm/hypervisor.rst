.. _hypervisor:

=======================
hypervisor
=======================

什么是Hypervisor
=======================

在现代的Hypervisor设计中，分为两类:

- Type 1 hypervisor: 

Type 1 hypervisor是直接运行在硬件上，通过一个分离的hypervisor软件组件提供虚拟机运行，这种独立的bare-metal hypervisor，例如Xen

- Type 2 hypervisor: 

Type 2 hypervisor通常需要修改现有操作系统来运行虚拟机，这就需要集成一个虚拟机监控器(Virtual Machine Monitor,VMM)到主机操作系统源代码中，或者在主机操作系统中安装一个VMM驱动。 例如，KVM就是集成在host主机操作系统内核中的hosted hypervisor，而著名的虚拟化软件VMware Workstation就是在现有操作系统内核中加载一个VMM驱动来监视虚拟机。

.. figure:: ../_static/kvm/hypervisor_designs.webp

通常，Type 1 hypervisor需要为所有支持的硬件重新实现以便设备驱动。不过，Xen的Type 1 hypervisor是通过在hypervisor中实现一个最小化硬件集并且运行一个特殊的私有VM(Dom0)来实现一个Linux系统使用所有实际存在硬件。这样Xen就通过使用Dom0来驱动I/O使用硬件设备，实现了所有虚拟机DomUs的硬件使用。



参考
=======

- `On the Performance of Arm Virtualization <https://www.linaro.org/blog/on-the-performance-of-arm-virtualization/>`_
