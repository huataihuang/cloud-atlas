.. _gentoo_nvidia:

===================
Gentoo NVIDIA驱动
===================

``x11-drivers/nvidia-drivers`` 是NVIDIA闭源显卡驱动，另一个开源替代驱动是 ``nouveau`` 。为了能够更好发挥硬件性能，以及 :ref:`cuda` 用于 :ref:`machine_learning` ，可以安装NVIDIA官方驱动。

``x11-drivers/nvidia-drivers`` 包含了一些包装功能，提供了两部分: 内核模块以及X11驱动。

硬件兼容性
============

``x11-drivers/nvidia-drivers`` 实际上是一系列驱动，需要根据显卡硬件类型进行区分，特别是古早的NVIDIA显卡，不能安装过于新型的驱动。我的笔记本 :ref:`mbp15_late_2013` 使用的是 ``NVIDIA GeForce GT 750M, 2GB显存(GDDR5)`` 显卡。在 :ref:`archlinux_on_mbp` 实践中已经验证，只能安装NVIDIA官方提供的 ``nvidia-470xx-dkms`` ，所以在Gentoo中，也必须选择 ``470.161.03`` 版本。

- 创建一个 ``/etc/portage/package.mask/nvidia`` 配置，内容如下::

   >x11-drivers/nvidia-drivers-510

这里会屏蔽 ``510.108.03`` 及以上版本，所以 ``emerge`` 安装就会自动选择 ``470.161.03`` 版本。

安装
======

::

   emerge --ask x11-drivers/nvidia-drivers

内核
-----

NVIDIA内核驱动需要针对当前内核进行模块编译，所以内核必须支持内核模块加载功能，而且还需要完成特定的 :ref:`gentoo_kernel` 支持，否则会在安装NVIDIA驱动时提示报错。

使用 ``genkernel all`` 就会配置所有必要支持选项。如果有问题，则检查确保以下选项开启:

.. literalinclude:: gentoo_nvidia/kernel_nvidia
   :caption: 内核支持NVIDIA配置

.. note::

   如果没有定制 :ref:`gentoo_kernel` ，则直接安装 ``x11-drivers/nvidia-drivers`` 会出现冲突错误而失败

这里执行 ``make modules_install`` 有一个提示::

   depmod: WARNING: /lib/modules/6.1.12-gentoo-xcloud/video/nvidia-modeset.ko needs unknown symbol acpi_video_backlight_use_native

安装 ``nvidia-drivers``
--------------------------

- 安装 ``nvidia-drivers`` 私有驱动:

.. literalinclude:: gentoo_nvidia/install_nvidia
   :caption: 安装NVIDIA驱动

.. note::

   每次内核重新编译，则需要重新做一次 ``nvidia-drivers`` 私有驱动安装

检查::

   # lsmod | grep nvidia
   nvidia_drm             61440  0
   nvidia_modeset       1150976  1 nvidia_drm
   nvidia              34840576  1 nvidia_modeset
   drm_kms_helper        159744  1 nvidia_drm
   drm                   499712  4 drm_kms_helper,nvidia,nvidia_drm

问题排查
=========

重启后字符终端黑屏
----------------------

:ref:`gentoo_mbp_kernel` 我遇到一个奇怪的问题，就是重启系统后完全黑屏，没有任何输出。但是 :ref:`mbp15_late_2013` 的Gentoo Linux 正常启动的，能够ssh远程登陆。并且 ``lsmod | grep nvidia`` 证明已经正确加载内核模块，说明 ``nvidia-drivers`` 安装正确。

参考 `Gentoo: NVIDIA/nvidia-drivers <https://wiki.gentoo.org/wiki/NVIDIA/nvidia-drivers>`_ 提示:

The "Mark VGA/VBE/EFI FB as generic system framebuffer" option moved in kernel 5.15 with a new symbol name for all arches. This may cause a black screen or no progress shown after the loader on boot if changes are not made.

也就是说在内核中必须激活 simgple framebuffer ，否则重启系统会出现黑屏无法显示启动进度，也不能显示终端界面。注意，内核 5.15 之前和之后的simple framebuffer配置选项采用了不同的符号名，配置方法略有不同。

我检查了我的 ``make menuconfig``  配置，对于目前Gentoo 6.1.12 内核，默认 ``Simple framebuffer driver`` 是模块化编译。但是，我尝试将 ``Simple framebuffer driver`` 编译进内核，启动以后确实可以显示，但是却带来的花屏，见下文。

后来在处理 "字符终端花屏" 的NVIDIA提示，感觉是之前误激活了 ``CONFIG_DRM_SIMPLEDRM`` 导致的，还有一种可能就是没有配置任何framebuffer，但是同时又没有安装 ``nvidia-drivers`` (提供了framebuffer驱动模块)

字符终端花屏
------------------

我在上文中将 ``Simple framebuffer driver`` build-in，重启确实有屏幕输出，但是字符终端开始正常显示到登陆界面，但是输入交互时候就发现不对劲: 反馈的文字全部花屏

想到刚才遇到的安装提示::

   * Detected potential configuration issues with used kernel:
   *   CONFIG_DRM_SIMPLEDRM: is builtin (=y), and may conflict with NVIDIA
   *     (i.e. blanks when X/wayland starts, and tty loses display).
   *     For prebuilt kernels, unfortunately no known good workarounds.
   *   CONFIG_SYSFB_SIMPLEFB: is set, this may prevent FB_EFI or FB_VESA
   *     from providing a working tty console display (ignore if unused).

.. literalinclude:: gentoo_nvidia/kernel_nvidia_simple_framebuffer_error_config
   :caption: ``错误激活`` simple framebuffer ，NVIDIA驱动安装后会提示冲突

去除上述冲突选项之后，编译安装 ``nvidia-drivers`` 确实不再提示冲突，但是花屏问题还没有解决。

参考
==========

- `Gentoo: NVIDIA/nvidia-drivers <https://wiki.gentoo.org/wiki/NVIDIA/nvidia-drivers>`_
