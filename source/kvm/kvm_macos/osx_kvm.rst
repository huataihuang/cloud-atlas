.. _osx_kvm:

================================
OSX-KVM: 在KVM虚拟环境运行macOS
================================

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
