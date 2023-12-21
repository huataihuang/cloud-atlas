.. _osx_kvm:

================================
OSX-KVM: 在KVM虚拟环境运行macOS
================================

KVM提供了不需要修改Guest操作系统的虚拟化运行，也支持将macOS作为Guest运行。网上有不少通过KVM运行macOS的教程，并且 `foxlet/macOS-Simple-KVM <https://github.com/foxlet/macOS-Simple-KVM>`_ 提供了一个快速设置macOS VM的工具方便我们实现。

目前已经有不少云计算厂商提供了虚拟化运行macOS的产品，如AWS，Azure等，甚至有提供纯macOS托管和虚拟化的 `MacStadium <https://www.macstadium.com>`_ , `MacinCloud <https://www.macincloud.com>`_ 和 `Fkiw <https://flow.swiss>`_ 。从开发移动应用需要大量的测试环境来说，macOS的虚拟化云计算有技术和市场价值，值得探索研究。

.. note::

   注意， `OSX-KVM <https://github.com/kholia/OSX-KVM>`_ 是在Linux KVM中运行 macOS，不需要苹果的硬件。这和苹果公司推出的 macOS Virtualization 技术是不同的，苹果公司的的虚拟化技术是在 :ref:`macos` 内部提供 Virtualization framework，来提供运行Linux虚拟机、macOS虚拟机的能力。

   **虽然 OSX-KVM 不是基于苹果操作系统macOS的Virtualization技术，但是为了方便归类，我还是列在了 macOS Virtualization 专栏里面**

`OSX-KVM <https://github.com/kholia/OSX-KVM>`_ 是一个开源KVM环境运行macOS的解决方案，我们可以通过虚拟机运行不同的macOS操作系统，实现开发和测试。目前是在 ``Intel VT-x / AMD SVM`` 处理器上实现，或许有一天能够在ARM架构上实现。

.. note::

   `Docker-OSX <https://github.com/sickcodes/Docker-OSX>`_ 项目使用了 `OSX-KVM <https://github.com/kholia/OSX-KVM>`_ 和 `KVM-Opencore <https://github.com/thenickdude/KVM-Opencore>`_ 实现了容器化OSX，后续也值得研究实践

   `Mac OS X KVM with GPU Passthrough | Gentoo Linux <https://iphonewired.com/common-problems/197739/>`_ 提供了一个针对Nvidia显卡的加速指南

   另外两个可参考项目:

   - `joeknock90 / Single-GPU-Passthrough <https://github.com/joeknock90/Single-GPU-Passthrough>`_
   - `foxlet / macOS-Simple-KVM <https://github.com/foxlet/macOS-Simple-KVM>`_

参考
======

- `OSX-KVM <https://github.com/kholia/OSX-KVM>`_
- `Mac OS VM Guide Part 2 (GPU Passthrough and Tweaks) <https://passthroughpo.st/mac-os-vm-guide-part-2-gpu-passthrough-and-tweaks/>`_
- `yoonsikp / macOS-KVM-PCI-Passthrough <https://github.com/yoonsikp/macOS-KVM-PCI-Passthrough>`_ 提供了详细文档
