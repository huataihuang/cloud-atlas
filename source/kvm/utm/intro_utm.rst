.. _intro_utm:

=====================================
macOS和iOS平台QEMU虚拟化实现:UTM简介
=====================================

UTM是一个面向iOS和macOS的全功能操作系统模拟器，基于 :ref:`qemu` 移植。简而言之，UTM可以在 :ref:`macos` 和 :ref:`ios` (包括Mac, iPhone 和 iPad)上运行Window, Linux 甚至各种操作系统。

UTM采用 :ref:`apple_hypervisor` 虚拟化框架：

- 可以在Apple Silicon上以接近本机的速度运行ARM64操作系统(可以在macOS中运行macOS)

  - 底层采用 :ref:`apple_virtualization` 原生性能

- 可以在Apple Silicon上使用较低型性能的仿真运行 x86/x64 操作系统
- 可以在Intel Mac上，以虚拟化运行 x86/x64 操作系统
- 可以在Intel Mac上，以虚拟化运行 ARM64 操作系统
- 此外还可以运行任意硬件架构(完全模拟性能较差): ARM32、MIPS、PPC 和 RISC-V

UTM的底层核心是 :ref:`qemu` 以及 :ref:`apple_virtualization` (我最初以为UTM是纯 :ref:`qemu` 软件，但是阅读官方文档发现实际上在满足 :ref:`macos` 版本要求情况下，可以直接使用 :ref:`apple_virtualization` 进行原生加速)

USB设备支持
============

在 :ref:`lima_run_freebsd` 我发现VZ虚拟化无法使用USB设备，这个问题在UTM也是相同，目前也无法在 :ref:`apple_virtualization` 虚拟化模式下为虚拟机连接外接USB设备。不过，在 :ref:`qemu` 虚拟化模式下，是可以直接在交互界面上选择 ``USB`` 图标直接将外接USB设备连接到虚拟机使用，非常类似 :ref:`vmware_fusion` 。

参考
=======

- `UTM FAQ <https://getutm.app/faq/>`_
- `getutm.app <https://getutm.app/>`_ UTM面向 :ref:`ios` 的官网
- `mac.getutm.app <https://mac.getutm.app/>`_ UTM面向 :ref:`macos` 的官网
- `GitHub utmapp/UTM <https://github.com/utmapp/UTM>`_
