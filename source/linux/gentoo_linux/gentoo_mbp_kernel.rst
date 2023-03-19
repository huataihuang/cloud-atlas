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

显卡
------

由于 :ref:`mbp15_late_2013` 具备了Intel集成显卡和NVIDIA显卡，所以如果准备使用开源驱动(intel开源驱动和 ``Nouveau`` 开源驱动)，则应该将两个显卡的支持都编译，即使只准备使用其中之一。因为这样编译了两个显示驱动，依然可以通过 ``vga_switcheroo`` 进行切换，而且这样也可以通过关闭其中一个显卡来节约能耗。

采用Intel显卡可以延长电池使用时间，不过这需要启动进入 :ref:`macos` 系统，然后使用 ``gfxCardStatus`` 来强制使用Intel显卡，然后使用 ``vga_switcheroo`` 来关闭NVIDIA显卡。

不幸的是，Intel显卡不支持多显示器。也就是说，如果需要使用多个显示器，不建议使用Intel显卡，即使它比较节约电池耗电。

使用NVIDIA的显卡也有限制，你不能控制显示屏的背光，而且停止x server将会进入黑屏，此时就必须重启主机。(确实如此，之前一直困扰给我的问题，看来是一个NVIDIA的限制)要么就使用显示登录管理器，也就是终止X server之后，显示管理器会自动再启动一个新的X server，避免进入黑屏。

使用NVIDIA显卡可以支持多显示器， ``ZaphodHeads`` 功能，或者简单地使用 ``xrandr``

内核配置
==========

.. literalinclude:: gentoo_mbp_kernel/process
   :caption: 处理器相关内核配置

- 考虑到主机性能有限，放弃 :ref:`kvm` 支持，采用纯 :ref:`docker` + :ref:`kind` ( :ref:`kubernetes` )

参考
======

- `Apple Macbook Pro Retina 15-inch (early 2013) <https://wiki.gentoo.org/wiki/Apple_Macbook_Pro_Retina_15-inch_(early_2013)>`_
- `Apple Macbook Pro Retina (early 2013) <https://wiki.gentoo.org/wiki/Apple_Macbook_Pro_Retina_(early_2013)>`_
