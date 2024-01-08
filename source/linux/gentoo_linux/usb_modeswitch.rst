.. _usb_modeswitch:

====================
usb_modeswitch
====================

``usb_modeswitch`` 是一种用于控制 'multi-mode' USB设备的模式切换工具:

- 许多 USB 设备（主要是高速 WAN 调制解调器）都具有板载 Windows 驱动程序: 第一次插入时，它们就像闪存一样，并从那里开始安装驱动程
- 安装后（以及每次连续插入），驱动程序会在内部切换模式，存储设备消失（在大多数情况下），并出现一个新设备（如 USB 调制解调器）

开源社区通过USB嗅探器(USB sniffing programs)和 ``libusb`` 来解析Windows驱动程序通讯，隔离触发模式切换的命令和操作，最后实现了在Linux和BSD系统重放相同序列。

``usb_modeswitch`` 通过在配置文件中获得参数完成所有初始化和通讯工作，然后在 ``libusb`` 帮助下实现动作。一般情况下， ``usb_modswitch`` 通过 :ref:`udev`

安装
==========

- 在Gentoo上安装:

.. literalinclude:: usb_modeswitch/gentoo_install
   :caption: 在Gentoo上安装 ``usb_modeswitch``

使用
==========

``usb_modeswith`` 被设计成开箱即用，只要插入设备，就会让 :ref:`udev` 自动工作。不过，如果你的设备不是已知设备，则需要使用 ``lsusb`` 获取设备的生产商(vender)和铲平(product) ID，运行相应命令或创建配置文件后运行命令。

在 :ref:`gentoo_mba_wifi` 我使用了以下命令将 BrosTrend 的 ``AX5L`` 从存储模式切换到WLAN模式 :

.. literalinclude:: gentoo_mba_wifi/usb_modeswitch_wifi
   :caption: 执行 ``usb_modeswitch`` 命令将 ``AX5L`` 从存储模式切换到WLAN模式

配置
=============

``usb_modeswitch`` 最佳使用方式是结合 :ref:`udev` ，通过事件驱动来采取对应的切换动作。对于我所使用的 :ref:`openrc` 也有对应的 :ref:`openrc_udev` 来配置当 :ref:`gentoo_mba_wifi` USB wlan设备插入时，自动切换存储模式和WLAN模式。

`How to automate usb_modeswitch? <https://askubuntu.com/questions/1247572/how-to-automate-usb-modeswitch>`_ 提供了一个案例可以借鉴，我修订成适合 ``AX5L`` **aic8800** 配置 


参考
=======

- `gentoo linux wiki: USB_ModeSwitch <https://wiki.gentoo.org/wiki/USB_ModeSwitch>`_
- `USB_ModeSwitch - Handling Mode-Switching USB Devices on Linux <https://www.draisberghof.de/usb_modeswitch/>`_
- `How to automate usb_modeswitch? <https://askubuntu.com/questions/1247572/how-to-automate-usb-modeswitch>`_
