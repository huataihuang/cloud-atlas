.. _gentoo_mbp_kernel:

=====================================
Gentoo内核编译(MacBook Pro Late 2013)
=====================================

硬件环境
==========

:ref:`install_gentoo_on_mbp` ( :ref:`mbp15_late_2013` )后，对内核进行定制，以便能够充分发挥硬件性能。本文综合 :ref:`mbp15_late_2013` 内核编译的要点。

- ``lspci -nn`` 输出:

.. literalinclude:: gentoo_mbp_kernel/lspci_output
   :caption: ``MacBook Pro Late 2013`` 上执行 lspci -nn 输出

- ``lsusb`` (软件包 ``usbutils`` )输出:

.. literalinclude:: gentoo_mbp_kernel/lsusb_output
   :caption: ``MacBook Pro Late 2013`` 上执行 lsusb 输出

USB快速以太网卡
-----------------

我需要支持USB以太网卡::

   Bus 002 Device 004: ID 0bda:8153 Realtek Semiconductor Corp. RTL8153 Gigabit Ethernet Adapter

.. literalinclude:: gentoo_mbp_kernel/usb_fast_ethernet_adapter
   :caption: 内核配置支持USB快速以太网卡(Realtek RTL8153 Gigabit Ethernet Adapter)

以及 :ref:`android_usb_tethering` 所使用的 `Gentoo linux - Android USB Tethering <https://wiki.gentoo.org/wiki/Android_USB_Tethering>`_ 所以还需要内核 ``USB Network Adapters`` 驱动支持，启用 ``Host for RNDIS and ActiveSync devices``

显卡
------

由于 :ref:`mbp15_late_2013` 具备了Intel集成显卡和NVIDIA显卡，所以如果准备使用开源驱动(intel开源驱动和 ``Nouveau`` 开源驱动)，则应该将两个显卡的支持都编译，即使只准备使用其中之一。因为这样编译了两个显示驱动，依然可以通过 ``vga_switcheroo`` 进行切换，而且这样也可以通过关闭其中一个显卡来节约能耗。

采用Intel显卡可以延长电池使用时间，不过这需要启动进入 :ref:`macos` 系统，然后使用 ``gfxCardStatus`` 来强制使用Intel显卡，然后使用 ``vga_switcheroo`` 来关闭NVIDIA显卡。

不幸的是，Intel显卡不支持多显示器。也就是说，如果需要使用多个显示器，不建议使用Intel显卡，即使它比较节约电池耗电。

使用NVIDIA的显卡也有限制，你不能控制显示屏的背光，而且停止x server将会进入黑屏，此时就必须重启主机。(确实如此，之前一直困扰给我的问题，看来是一个NVIDIA的限制)要么就使用显示登录管理器，也就是终止X server之后，显示管理器会自动再启动一个新的X server，避免进入黑屏。

使用NVIDIA显卡可以支持多显示器， ``ZaphodHeads`` 功能，或者简单地使用 ``xrandr``

我在编译内核完内核执行 ``make modules_install`` 有一个报错::

   depmod: WARNING: /lib/modules/6.1.12-gentoo-xcloud/video/nvidia-drm.ko needs unknown symbol drm_compat_ioctl

看起来是私有Nivida驱动会提供，执行 :ref:`gentoo_nvidia` 之后就没有这个WARNING了

.. note::

   设备驱动实在太繁杂了，内核大多数代码和配置开关都是有关驱动的，很多设备闻所未闻。我尽量削减配置，这样可以将内核精简，并且减少编译时间(即使是模块不占内存空间但是编译时间太长了)


内核配置
==========

.. literalinclude:: gentoo_mbp_kernel/process
   :caption: 处理器相关内核配置

- 考虑到主机性能有限，放弃 :ref:`kvm` 支持，采用纯 :ref:`docker` + :ref:`kind` ( :ref:`kubernetes` )

- Apple相关硬件内核配置: 

.. literalinclude:: gentoo_mbp_kernel/apple_mbp
   :caption: Apple MBP相关内核配置

- 确保以下选项没有选择，以便使用Broadcom私有无线驱动:

.. literalinclude:: gentoo_mbp_kernel/apple_mbp_disable
   :caption: Apple MBP需要关闭的选项(以便使用私有驱动)

内核编译安装以后，立即完成 :ref:`gentoo_mbp_wifi` 和 :ref:`gentoo_nvidia` ，因为这两者都是私有软件，需要作为模块编译到内核。

参考
======

- `Apple Macbook Pro Retina 15-inch (early 2013) <https://wiki.gentoo.org/wiki/Apple_Macbook_Pro_Retina_15-inch_(early_2013)>`_
- `Apple Macbook Pro Retina (early 2013) <https://wiki.gentoo.org/wiki/Apple_Macbook_Pro_Retina_(early_2013)>`_
- `Gentoo linux - USB Fast Ethernet Adapter <USB Fast Ethernet Adapter>`_
- `Gentoo linux - Android USB Tethering <https://wiki.gentoo.org/wiki/Android_USB_Tethering>`_
