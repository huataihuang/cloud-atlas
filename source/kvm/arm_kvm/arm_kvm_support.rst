.. _arm_kvm_support:

====================
ARM对KVM支持概述
====================

.. figure:: ../../_static/kvm/arm_kvm/kvm-arm-logo.png

.. note::

   2020年3月，Linux 5.7 Kernel宣布将放弃支持 32位架构的 KVM虚拟化支持，所以目前来看，要想较好的在ARM架构上运行KVM虚拟化，需要使用现代化的64位ARM架构。 - `Linux 5.7 Positioned To Retire ARM 32-bit KVM Virtualization Support <https://www.phoronix.com/scan.php?page=news_item&px=Linux-5.7-Kill-32-bit-ARM-KVM>`_

   Red Hat Enterprise Linux 7.5开始支持在64位ARM架构上运行KVM虚拟化，不过还处于试用阶段，并没有在生产环境支持。目前公开文档很少，不过，使用CentOS或Fedora的最新版本，都已经提供了ARM的64位架构发行版，可以使用体验。

ARM虚拟化概述
==============

- 在Linux Kernel 3.9开始，KVM支持ARM架构。不过，ARM架构对虚拟化和其他架构(x86, PowerPC)不同。大多数现代对32位ARM处理器，如Cortex-A15(最早在ARMv7-A处理器实现)，也包含了类似ARMv7架构扩展可以支持硬件虚拟化。虽然也有一些研究项目在尝试无需硬件虚拟化的ARM虚拟化实现，但是这些项目都需要使用某种级别的paravirtualization并且不够稳定。

- ARM引入了一个新的CPU模式来运行hypervisor，称为HYP模式，这是一个比SVC模式更为私有的模式。(对于ARM处理器，内核运行在SVC模式，用户空间运行在USR模式)

  - HYP模式的一个重要特征，也是KVM/ARM的设计核心，就是HYP模式不是SVC模式的扩展，而是一个明确的独立功能集合以及一个独立的虚拟内存转换机制。
  - 在HYP模式发生page fault(分页错误)，这个失败虚拟地址是存储在HYP的寄存器而不是SVC模式的寄存器。
  - 对于SVC和USR模式，硬件上使用了两个独立的页表基址寄存器(separate page table base registers)，用于提供我们输出的用户空间和内核空间地址空间隔离。
  - HYP模式只使用一个单页表基础寄存器，并且不允许地址空间分为用户模式和内核模式。

- ARM的HYP模式设计适合经典的bare-metal hypervisor: HYP hypervisor不重用任何在SVC模式下工作而编写的现有内核代码

  - 和x86的硬件虚拟化不同，x86对虚拟化支持没有提供新的CPU模式(仅切换CPU身份 ``non-root`` 和 ``root`` (虚拟机陷入hypervisor时CPU切换到 ``root`` 身份)):

    - x86采用了 "根" 和 "非根" ( "root" and "non-root" )概念: 在x86上使用 ``non-root`` 方式运行，则功能集完全等同于没有虚拟化支持的CPU；而以 ``root`` 方式运行，则功能集被扩展成添加了用于控制虚拟机(VM)的附加功能
    - 所有现有内核代码都可以以 "root" 和 "non-root" 模式运行而无需修改
    - 在x86上，当VM陷入(traps to)hypervisor，则CPU从 ``non-root`` 转为 ``root``

  - 在ARM上，当VM陷入hypervisor时，则CPU陷入HYP模式

- ARM的HYP模式通过将敏感操作(sensitive operations)配置为在SVC和USR模式下执行时陷入HYP模式来控制虚拟化功能
- ARM的HYP模式允许hypervisor配置一些影子寄存器值(shadown register values)，用于向VM隐藏有关物理硬件的信息
- ARM的HYP模式还控制Stage-2转换，类似于Intel用于控制VM内存访问的"扩展也表"(extended page table)
- 当ARM处理器发出 load/store 指令是，指令中使用的内存地址由内存管理单元(memory management unit, MMU)使用常规页表(regular page)从虚拟地址(virtual address)转换到物理地址(physical address)::

   Virtual Address (VA) -> Intermediate Physical Address (IPA)

- ARM的虚拟化扩展添加了一个额外的转换阶段称为 ``Stage-2`` 转换，只能通过HYP模式启用和禁用。启用 ``Stage-2`` 转换之后，MMU按照以下方式转换地址::

   Stage-1: Virtual Address (VA) -> Intermediate Physical Address (IPA)
   Stage-2: Intermediate Physical Address (IPA) -> Physical Address (PA)

- 在ARM的虚拟化环境中:

  - guest操作系统独立于hypervisor来控制 ``Stage-1`` 转换，并且可以更改映射和页表无需陷入hypervisor
  - ``Stage-2`` 转换由hypervisor控制，并且单独的 ``Stage-2`` 页表基址寄存器(page table base register)只能从HYP模式访问
  - 通过使用 ``Stage-2`` 转换来允许运行在HYP模式的软件以完全透明的方式访问一个运行在SVC或USR模式的VM的物理地址，这是因为VM只能访问hypervisor已经将 ``Stage-2`` 页表中的从中间物理地址(IPA)映射到物理地址(PA)的内存页面

KVM/ARM设计
============

待续

参考
======

- `Supporting KVM on the ARM architecture <https://lwn.net/Articles/557132/>`_ 本文主要参考，有很多原理还需要深入学习
- `arm Developer: AArch64 virtualization <https://developer.arm.com/documentation/100942/0100/AArch64-virtualization>`_ ARM官方文档
- `On the Performance of Arm Virtualization <https://www.linaro.org/blog/on-the-performance-of-arm-virtualization/>`_
- `Virtual Open Systems: KVM on ARM virtualization - An introduction <http://lia.disi.unibo.it/Courses/som1516/materiale/VOSYS_BolognaKVMARM_2_12_2015.pdf>`_ Virtual Open Systems公司将KVM port到ARM(Linux Kernel 3.9,2012年)
- Red Hat Enterprise Linux7Virtualization Deployment and Administration GuideB.3. Using KVM Virtualization on ARM Systems
