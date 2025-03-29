.. _archlinux_build_kernel:

==========================
Arch Linux编译内核
==========================

在尝试 :ref:`install_waydroid_asahi_linux` 发现通过 :ref:`archlinux_aur` 安装内核模块来支持 :ref:`waydroid` 还是依赖于arch linux的旧版本内核头文件，没有对应的asahi linux软件包。虽然我很想自己编译，但是查阅文档发现asahi linux的特定硬件支持编译可能并非像arch linux这般标准化，所以我暂时没有尝试 :ref:`asahi_linux` 的内核编译，有待后续再学习asahi linux的时候尝试。

这里简要记录方法，为后续x86硬件平台Arch Linux定制做准备

准备工作
==========

- 在个人目录下准备 ``makepkg`` ，首先按安装 ``asp`` 和 ``base-devel`` :

.. literalinclude:: archlinux_build_kernel/asp_base-devel
   :language: bash
   :caption: 安装 asp 和 base-devel

- 创建编译目录并准备PKGBUILD源代码:

.. literalinclude:: archlinux_build_kernel/pkgbuild_kernel
   :language: bash
   :caption: 准备PKGBUILD目录和源代码

修改PKGBUILD
=================

修改 ``linux/PKGBUILD`` ，其中有一些简单的参数，例如::

   pkgbase=linux-custom

这是内核的命名，其实就是 ``make menuconfig`` 中对编译后内核名字进行区分

编译
======

- 执行编译::

   makepkg -s

这里参数 ``-s`` 会下载所有依赖以及最新源代码进行编译

编译完成后，会在 ``~/build/linux`` 目录下形成类似::

   linux-custom-5.8.12-x86_64.pkg.tar.zst
   linux-custom-headers-5.8.12-x86_64.pkg.tar.zst

安装::

   pacman -U linux-custom-headers-5.8.12-x86_64.pkg.tar.zst linux-custom-5.8.12-x86_64.pkg.tar.zst


.. note::

   本文尚未实践，待续


参考
=====

- `Kernel/Arch Build System <https://wiki.archlinux.org/title/Kernel/Arch_Build_System>`_
- `Compile kernel module <https://wiki.archlinux.org/title/Compile_kernel_module>`_
- `Kernel/Traditional compilation <https://wiki.archlinux.org/title/Kernel/Traditional_compilation>`_
