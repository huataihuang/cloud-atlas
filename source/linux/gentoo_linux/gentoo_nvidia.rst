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
~~~~~~

NVIDIA内核驱动需要针对当前内核进行模块编译，所以内核必须支持内核模块加载功能，而且还需要完成特定的 :ref:`gentoo_kernel` 支持，否则会在安装NVIDIA驱动时提示报错。

使用 ``genkernel all`` 就会配置所有必要支持选项。如果有问题，则检查确保以下选项开启:

.. literalinclude:: gentoo_nvidia/kernel_nvidia
   :caption: 内核支持NVIDIA配置

.. note::

   如果没有定制 :ref:`gentoo_kernel` ，则直接安装 ``x11-drivers/nvidia-drivers`` 会出现冲突错误而失败

安装 ``nvidia-drivers``
~~~~~~~~~~~~~~~~~~~~~~~~~

.. warning::

   The "Mark VGA/VBE/EFI FB as generic system framebuffer" option moved in kernel 5.15 with a new symbol name for all arches. This may cause a black screen or no progress shown after the loader on boot if changes are not made.

   在内核中必须激活 simgple framebuffer ，否则重启系统会出现黑屏无法显示启动进度，也不能显示终端界面。注意，内核 5.15 之前和之后的simple framebuffer配置选项采用了不同的符号名，配置方法略有不同。

   目前Gentoo 6.1.12 内核，默认 ``Simple framebuffer driver`` 是模块化编译。

   我遇到一个问题就是编译后内核能够正常启动主机(ssh可以登陆)，但是屏幕完全黑屏无输出，而且安装了 ``nvidia-drivers`` 之后也是一样( ``lsmod | grep nvidia`` 证明已经正确加载内核模块 )

- 安装 ``nvidia-drivers`` 私有驱动:

.. literalinclude:: gentoo_nvidia/install_nvidia
   :caption: 安装NVIDIA驱动

参考
==========

- `Gentoo: NVIDIA/nvidia-drivers <https://wiki.gentoo.org/wiki/NVIDIA/nvidia-drivers>`_
