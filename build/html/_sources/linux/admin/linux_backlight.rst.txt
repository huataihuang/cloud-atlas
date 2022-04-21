.. _linux_backlight:

========================
Linux屏幕背光
========================

当黎明或深夜时，使用Linux主机进行开发和运维工作，你会感到屏幕的背光十分刺目，让你双眼酸痛。然而，显示器的内置硬件调整菜单非常原始，调整起来既麻烦又无法快速恢复。这时候，你会想是否可以像Mac主机一样，通过快捷按键来调整屏幕亮度呢？

在Linux系统中，除了硬件厂商直接提供的特定快捷键外，还可以提供过两种软件方式来设置屏幕亮度:

- 通过 ACPI ( :ref:`pi_uefi_acpi` )、显卡或者平台驱动，可以将屏幕背光控制输出到 ``/sys/class/backlight`` ，这样就能通过用户侧 ``backlight`` 工具来控制
- 通过 ``setpci`` 可以向显卡寄存器设置值

.. note::

   :ref:`raspberry_pi` 默认没有使用 :ref:`pi_uefi` ，所以无法启用ACPI，也就无法通过ACPI调整显示器背光。这个问题，后续我将在完成 :ref:`pi_uefi_acpi` 转换后再次实践。

硬件接口
===========

ACPI
-------

屏幕背光亮度是同u哦设置LEDs的能源级别实现的，这个能源级别通常使用视频的ACPI内核模块控制。这个模块的接口通过 ``sysfs`` 目录 ``/sys/class/backlight/`` 来提供。

需要注意ACPI BIOS提供了通过通用ACPI接口控制背光的，但是没有具体模式的实现。所以需要硬件提供ACPI驱动注册，并且不能使用任何笔记本专用驱动。满足上述条件之后，就可以在内核启动参数中添加::

   acpi_backlight=vendor

如果是thinkpad设备，则还需要激活 ``thinkpad-acpi`` 驱动::

   thinkpad-acpi.brightness_enable=1

注意，内核接口需要有 ``/proc/acpi/video`` ，对于 :ref:`raspberry_pi` 需要 :ref:`pi_uefi` 支持才能实现::

   /proc/acpi/video/
    |
    +- <GFX card>
    |   |
    |   +- <Display Device>
    |   |   |
    |   |   +- EDID
    |   |   +- brightness
    |   |   +- state
    |   |   +- info
    |   +- ...
    +- ...

.. note::

   `ubuntu wiki: Backlight <https://wiki.ubuntu.com/Kernel/Debugging/Backlight>`_ 文档中有很多检查案例方法，待后续 :ref:`pi_uefi_acpi` 环境具备后实践

通过以下命令可以检查目录下显卡型号::

   ls /sys/class/backlight/

注意，需要具备ACPI支持的显卡，例如ATI显卡，Intel显卡等等，可能会有如下子目录::

   acpi_video0

.. note::

   目前我没有相应测试环境，例如 :ref:`raspberry_pi` 不支持ACPI，没有 ``/sys/class/backlight/`` 目录

- 在启用了ACPI的环境中，可以检查 ``/sys/class/backlight/acpi_video0/`` ，输出类似::

   actual_brightness  brightness         max_brightness     subsystem/    uevent             
   bl_power           device/            power/             type

- 检查显示可以支持的最大亮度::

   cat /sys/class/backlight/acpi_video0/max_brightness

例如输出::

   15

- 通过命令调整亮度值::

   echo 5 > /sys/class/backlight/acpi_video0/brightness

- 默认情况下，只有root用户可以调整。不过，可以设置社诶属性允许普通用户调整。即更改 udev 规则 ``/etc/udev/rules.d/backlight.rules`` ::

   ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="acpi_video0", GROUP="video", MODE="0664"

树莓派
=======

`linusg/rpi-backlight <https://github.com/linusg/rpi-backlight>`_ 是一个Python模块可以用来控制树莓派官方提供的Raspberry Pi 7" touch display显示器的功耗和亮度。并且提供了详细的 `rpi-backlight Documentation <https://rpi-backlight.readthedocs.io/en/latest/index.html>`_ 。

结合光线传感器，可以实现 `Automated brightness control for the Raspberry Pi <http://www.yoctopuce.com/EN/article/automated-brightness-control-for-the-raspberry-pi>`_

参考
=======

- `arch linux wiki: Backlight <https://wiki.archlinux.org/title/backlight>`_
- `ubuntu wiki: Backlight <https://wiki.ubuntu.com/Kernel/Debugging/Backlight>`_
- `Display Backlight Control in the Sway <https://danmc.net/posts/sway-backlight/>`_ 控制背光原理是相通的，不过本文提供了在 :ref:`sway` 环境绑定快捷键调整背光亮度的方法
