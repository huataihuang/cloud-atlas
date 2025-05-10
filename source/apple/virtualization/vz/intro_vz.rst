.. _intro_vz:

=========================
VZ 简介
=========================

 `vz - Go binding with Apple Virtualization.framework <https://github.com/Code-Hex/vz>`_ :

- ``vz`` 支持macOS Big Sur (11.0.0) (我是尝试在Big Sur上 :ref:`colima_tunning` )
- Mac上Linux虚拟化(x86_64,arm64)

  - 支持GUI
  - 支持EFI ROM
  - 通过SPICE agent支持剪贴板共享

- Apple Silicon Macs(arm64)支持macOS虚拟化: 需要注意，VZ只能在ARM架构支持macOS

  - 支持从网络获取restore镜像
  - 支持recovery模式启动

- 支持共享目录
- 支持Virtio Sockets
- 较少的依赖

``VZ`` 主要使用 :ref:`golang` 开发来整合 :ref:`apple_virtualization` :

- 使用了 `PUI PUI Linux <https://github.com/Code-Hex/puipui-linux>`_ (一个仅使用Apple Virtualization.framework Virtio功能)来测试Linux功能
- :ref:`linuxkit` ( :ref:`moby` 的组件，用于构建定制化Linux发行版)使用了 ``VZ`` 库
- :ref:`vfkit` 通过 ``VZ`` 库提供了 :ref:`apple_virtualization` (Intel和Apple Silicon)大多数功能
- :ref:`lima` 通过 ``VZ`` 构建使用 :ref:`apple_virtualization` 作为底层的Linux虚拟机

参考
======

- `vz - Go binding with Apple Virtualization.framework <https://github.com/Code-Hex/vz>`_
