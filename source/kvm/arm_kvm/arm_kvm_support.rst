.. _arm_kvm_support:

====================
ARM对KVM支持概述
====================

.. figure:: ../../_static/kvm/arm_kvm/kvm-arm-logo.png

在Linux Kernel 3.9开始，KVM支持ARM架构。不过，ARM架构对虚拟化和其他架构(x86, PowerPC)不同。大多数现代对32位ARM处理器，如Cortex-A15，也包含了类似ARMv7架构扩展可以支持硬件虚拟化。虽然也有一些研究项目在尝试无需硬件虚拟化的ARM虚拟化实现，但是这些项目都需要使用某种级别的paravirtualization并且不够稳定。

.. note::

   2020年3月，Linux 5.7 Kernel宣布将放弃支持 32位架构的 KVM虚拟化支持，所以目前来看，要想较好的在ARM架构上运行KVM虚拟化，需要使用现代化的64位ARM架构。 - `Linux 5.7 Positioned To Retire ARM 32-bit KVM Virtualization Support <https://www.phoronix.com/scan.php?page=news_item&px=Linux-5.7-Kill-32-bit-ARM-KVM>`_

   Red Hat Enterprise Linux 7.5开始支持在64位ARM架构上运行KVM虚拟化，不过还处于试用阶段，并没有在生产环境支持。目前公开文档很少，不过，使用CentOS或Fedora的最新版本，都已经提供了ARM的64位架构发行版，可以使用体验。 

从ARM处理器视角来看，内核运行在SVC模式，而用户空间运行在USR模式。ARM引入了一个新的CPU模式来运行hypervisor，称为HYP模式，这是一个比SVC模式更为私有的模式。HYP模式的一个重要特征，也是KVM/ARM的设计核心，就是HYP模式不是SVC模式的扩展，而是一个明确的独立功能集合以及一个独立的虚拟内存转换机制。例如，在HYP模式发生page fault，这个失败虚拟地址是存储在HYP的寄存器而不是SVC模式的寄存器。此外，对于SVC和USR模式，一年上使用了两个独立的页表基础寄存器(separate page table base registers)，用于提供我们输出的用户空间和内核空间地址空间隔离。HYP模式只使用一个单页表基础寄存器，并且不允许地址空间分为用户模式和内核模式。



参考
======

- `KVM Process support <https://www.linux-kvm.org/page/Processor_support>`_
- `Supporting KVM on the ARM architecture <https://lwn.net/Articles/557132/>`_
- `On the Performance of Arm Virtualization <https://www.linaro.org/blog/on-the-performance-of-arm-virtualization/>`_
- `Virtual Open Systems: KVM on ARM virtualization - An introduction <http://lia.disi.unibo.it/Courses/som1516/materiale/VOSYS_BolognaKVMARM_2_12_2015.pdf>`_
- Red Hat Enterprise Linux7Virtualization Deployment and Administration GuideB.3. Using KVM Virtualization on ARM Systems
