.. _install_waydroid_asahi_linux:

=========================
Asahi Linux安装Waydroid
=========================

.. note::

   :ref:`asahi_linux` 是基于 :ref:`arch_linux` 的ARM架构发行版，我尝试用 waydroid 来运行Android应用

CPU要求
=========

Android官方提供了 `android cpu列表 <https://developer.android.com/ndk/guides/abis#sa>`_ 看起来我所使用的 :ref:`apple_silicon_m1_pro` 属于 ARMv8 架构，似乎是支持的。

GPU要求
==========

Waydroid对Intel的GPU支持最好，几乎是开箱即用。

其次可以使用AMD GPU

但是NVIDIA GPU不能工作，只能采用以下两种woraround:

- 如果可能切换到内置显卡(例如很多笔记本电脑实际上除了NVIDIA GPU以外还在主板集成了Intel GPU)
- 采用软件渲染

Wayland session管理器
=======================

Waydroid只能工作在 :ref:`wayland` 会话管理器，所以即使在X11环境，很多Wayland session管理器支持堆叠会话(也就是在X11会话中运行Wayland会话)，典型的案例是 ``weston`` 。

内核模块
=========

Waydroid需要使用一种包含了 ``binder`` 模块以及可选的 ``ashmem`` 模块的Linux内核，这种内核并非 :ref:`arch_linux` 的默认内核。解决方法主要有:

- 安装 ``linux-zen`` 内核
- 安装 :ref:`dkms` 内核模块 ``anbox-modules-dkms-git`` (使用 :ref:`archlinux_aur` )并加载内核::

   yay -S anbox-modules-dkms-git 
   modprobe ashmem_linux
   modprobe binder_linux

.. note::

   很不幸，安装 ``anbox-modules-dkms-git`` 显示需要 ``5.19.0-asahi-5-1-ARCH`` 内核头文件...然而 :ref:`asahi_linux` 需要使用Kernel 6.1内核...

   暂时放弃尝试 :ref:`dkms` 内核模块方式，改为 :ref:`archlinux_build_kernel`

- 自己编译内核: :ref:`archlinux_build_kernel`



参考
=====

- `arch linux waydroid <https://wiki.archlinux.org/title/Waydroid>`_
