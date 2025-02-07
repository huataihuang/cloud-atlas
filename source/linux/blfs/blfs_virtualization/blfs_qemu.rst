.. _blfs_qemu:

===================
BLFS QEMU
===================

:ref:`qemu` 是x86硬件提供了虚拟化扩展(Intel VT / AMD-V)的完全虚拟化解决方案。

依赖
=====

- 必须:

  - :ref:`glib`
  - :ref:`pixman`

- 建议:

  - ``alsa-lib`` 考虑到我使用的虚拟机主要用于服务器，对音频没有需求，所以不安装这个ALSA库
  - ``dtc`` Device Tree Compiler，用于设备树源代码和二进制文件，例如 libfdt 以二进制格式读取和操作设备树，不确定是否需要，暂时不安装
  - ``libslirp`` 用于虚拟机，容器和相关工具的用户模式网络库，感觉有用，且只依赖 glib
  - ``sdl2`` Simple DirectMedia Layer Version 2: 跨平台用于编写多媒体软件，暂不安装

.. note::

   我只依赖编译安装了 ``libslirp`` ，不过实践验证使用并没有问题。包括VNC桌面也能够正常使用，见 :ref:`run_debian_in_qemu`

内核
========

- 以下内核配置需要激活以支持虚拟化

.. literalinclude:: blfs_qemu/kernel
   :caption: 内核支持

- 编译内核

.. literalinclude:: ../../lfs/lfs_boot/kernel_make                                                                           
   :caption: 编译内核

安装
=======

.. literalinclude:: blfs_qemu/qemu
   :caption: 安装qemu

.. _blfs_qemu_bridge:

BLFS qemu使用bridge网络
=========================

案例采用 :ref:`run_debian_in_qemu` :

.. literalinclude:: ../../../kvm/qemu/run_debian_in_qemu/qemu_install_debian
   :caption: 执行安装

添加qemu ACL配置
-------------------

.. warning::

   必须步骤

在BLFS的qemu章节，最后一段配置我最初忽略了，实际上和 :ref:`bridge_br0_config` 有一个对应的 ``qemu`` 配置 ``/etc/qemu/bridge.conf`` 通过以下命令构建:

.. literalinclude:: blfs_qemu/bridge.conf
   :caption: 生成bridge ``br0`` 对应配置指示qemu使用

如果没有这个 ``/etc/qemu/bridge.conf`` 配置文件，那么在执行 ``qemu-system-x86_64 ... -net nic,model=virtio,macaddr=52:54:00:00:00:01 -net bridge,br=br0 ...`` 会提示报错:

.. literalinclude:: blfs_qemu/bridge.conf_error
   :caption: 缺少 ``/etc/qemu/bridge.conf`` 配置导致使用bridge的qemu命令报错

加载tun内核模块
----------------

使用 bridge 网络时，需要访问 ``/dev/net/tun`` 设备，如果内核没有加载这个模块，会提示错误:

.. literalinclude:: blfs_qemu/tun_error
   :caption: 内核没有加载 ``tun`` 模块，则提示错误

手工加载模块:

.. literalinclude:: blfs_qemu/modprobe_tun
   :caption: 内核加载 ``tun`` 模块

配置启动加载模块:

.. literalinclude:: blfs_qemu/tun.conf
   :caption: 内核加载 ``tun`` 模块配置文件

BLFS qemu使用
================

- :ref:`run_debian_in_qemu` 常规安装
- :ref:`run_debian_gpu_passthrough_in_qemu` 支持UEFI模式并使用 ``vfio-pci`` 实现GPU passthrough
- :ref:`gpu_passthrough_in_qemu_install_nvidia_linux_driver`

参考
=====

- `BLFS: Chapter 8. Virtualization - qemu-9.0.2 <https://www.linuxfromscratch.org/blfs/view/stable/postlfs/qemu.html>`_
