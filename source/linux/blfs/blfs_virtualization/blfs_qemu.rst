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

内核
========

- 以下内核配置需要激活以支持虚拟化

.. literalinclude:: blfs_qemu/kernel
   :caption: 内核支持

安装
=======

**待完成**

.. literalinclude:: blfs_qemu/qemu
   :caption: 安装qemu

参考
=====

- `BLFS: Chapter 8. Virtualization - qemu-9.0.2 <https://www.linuxfromscratch.org/blfs/view/stable/postlfs/qemu.html>`_
