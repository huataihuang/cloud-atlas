.. _libvirt_hooks_qemu_gpu:

====================================
Libvirt QEMU Hook脚本动态绑定GPU
====================================

vender-reset
================

在针对 AMD Vega 架构（如 MI50 / Radeon VII / Vega 56/64）进行 PCIe 虚拟机直通时，由于 AMD 官方驱动在显卡重置（FLR）上存在设计缺陷，虚拟机关闭后极易触发经典的 “AMD Reset Bug”（表现为宿主机二次启动虚拟机卡死、黑屏或整个内核崩溃）。

业界解决该问题的标准方案是开源内核模块 `gnif/vendor-reset <https://github.com/gnif/vendor-reset>`_ 。由于 Ubuntu 26.04 使用了较新的 Linux 内核，官方的 vendor-reset 项目在较高版本的内核上可能需要配合 DKMS 正确安装并必须在系统引导早期加载。

参考
=====

- gemini
