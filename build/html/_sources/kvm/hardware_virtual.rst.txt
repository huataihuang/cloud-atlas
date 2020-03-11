.. _hardware_virtual:

=================
硬件虚拟化
=================

`Hardware virtualization <https://en.wikipedia.org/wiki/Virtualization#Hardware_virtualization>`_ 也称为平台虚拟化（platform virtualization），指创建的虚拟机就好像在真实主机上运行的操作系统。在硬件虚拟化的虚拟机中软件运行是和底层物理硬件资源隔离的，Guest操作系统和Host操作系统可以是完全不同内核和不同种类的操作系统。

在2005年和2006年，Intel和AMD分别提供了x86架构下的硬件辅助虚拟化技术。其中，Intel虚拟化技术称为 ``VT-x`` ，在笔记本到服务器的很多主流Intel芯片都提供了VT-x虚拟化技术支持。在 :ref:`kvm` 中，我实践的KVM虚拟化技术也是依赖于Intel VT-x硬件辅助虚拟化实现的。

要检查Intel处理器是否支持硬件辅助虚拟化，在Linux操作系统中通过 ``/proc/cpuinfo`` 检查是否包含 ``vmx`` 关键字；或者在 macOS中通过命令检查 ``sysctl machdep.cpu.features`` 检查。

``vmx`` 即 Virtual Machine Extensions (虚拟机扩展)，添加了10条新指令: VMPTRLD, VMPTRST, VMCLEAR, VMREAD, VMWRITE, VMCALL, VMLAUNCH, VMRESUME, VMXOFF, 和 VMXON 。这些指令允许进入和退出一个虚拟化执行模式，此时guest OS以为自己运行在完全权限（ring 0），而其实Host OS依然受到保护。

嵌套虚拟化
===============

嵌套虚拟化在guest操作系统内部也提供了hypervisor功能，这样第一层虚拟机内部还可以再运行第二层虚拟机，对于云计算平台，甚至可以嵌套不同的云计算技术，例如在OpenStack云计算环境中嵌套运行Vmware云计算平台，对于一些传统的IT架构可以无缝迁移到新的云计算平台。

嵌套虚拟化的实现是基于 `硬件辅助虚拟化 <https://en.wikipedia.org/wiki/Hardware-assisted_virtualization>`_ 的切分计算机架构来实现的。如果没有提供硬件支持的嵌套虚拟化，一些软件技术也能够实现嵌套虚拟化，不过现在越来越多的嵌套虚拟化是需要硬件支持的。例如，从Intel Haswell微架构开始（2013年），Intel开始提供 `VMCS shadowing <https://en.wikipedia.org/wiki/VMCS_shadowing>`_ 技术来支持嵌套虚拟化加速。

- :ref:`intel_vmcs`

.. note::

   我所使用的模拟集群部署的MacBook Pro 2015 later恰好是等同于Haswell的Crystal Well系列处理器（ :ref:`intel_core_i7_4850hq` ），在 :ref:`kvm_nested_virtual` 我就只需要使用一台MacBook Pro来模拟OpenStack集群。请参考我的 :ref:`kvm_nested_virtual` 来了解嵌套虚拟化的神奇能力。


