.. _intro_virtualbox:

================
VirtualBox简介
================

VirtualBox最早是InnoTek Systemberatung GmbH开发的x86虚拟化主机hypervisor，该公司于2008年被Sun公司收购，而Sun公司则于2010年被Oracle公司收购。所以目前VirtualBox被命名为 Oracle VM VirtualBox，作为Oracle的虚拟化技术堆栈的一部分。

VirtualBox是一个跨平台虚拟化技术，可以运行在微软Windows, :ref:`macos` , :ref:`linux` , :ref:`solaris` 等系统上，甚至被移植到 :ref:`freebsd` 和 Genode系统。可以管理和运行多种guest虚拟机，如Windows, Linux, BSD, OS/2, Solaris, Haiku, Hackintosh (类似在Apple硬件上运行macOS虚拟机，但实际上是非Apple认证的通用x86硬件)。

.. note::

   VirtualBox的核心程序，从2010年12月开始的4系列，是采用自由软件GPLv2授权，而支持USB，远程卓敏啊协议RDP，磁盘加密，NVMe，EXE启动则作为私有协议发布(VirtualBox Oracle VM VirtualBox extension pack)，包含了闭源组件。这个扩展包只允许个人，教育和评估使用。此外从VirtualBox 4.1.30开始，Oracle将个人使用定义为非商业目的的单一计算机使用。

.. note::

   我在工作中主要使用 :ref:`kvm` 虚拟化，不过由于近期旅行途中，使用 :ref:`macos` 作为主要工作平台，所以需要一个比较完善的macOS平台的虚拟化解决方案。VirtulBox由于跨平台且使用简单，所以被我用于日常构建Linux开发测试环境(另外一个主要的开发测试环境是 :ref:`docker_desktop` ，想通过虚拟化方式来学习 :ref:`lfs`

host OS
=========

作为跨平台软件，VirtualBox支持以下操作系统作为host OS(也就是物理主机操作系统):

- 64位Windows: 从Windows 8.1 到 Windows Server 2022
- 64位macOS: 从10.15(Catalina)到13(Ventura)；注意目前主要支持Intel硬件，对于ARM架构的Apple silicon平台目前只提供技术预览版本，不能用于生产环境
- 64位Linux: Red Hat和Debian家族的各大发行版；对于其他Linux发行版，如果内核满足VirtualBox运行要求( :ref:`kernel` 2.6以上)，则可以手工安装
- 64位Oracle Solaris: 11.4

.. note::

   host系统的CPU需要支持SSE2(Streaming SIMD Extensions 2)


参考
======

- `Oracle VM VirtualBox docs <https://docs.oracle.com/en/virtualization/virtualbox/index.html>`_
- `Wikipedia: VirtualBox <https://en.wikipedia.org/wiki/VirtualBox>`_
