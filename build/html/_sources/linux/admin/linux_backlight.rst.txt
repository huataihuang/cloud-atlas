.. _linux_backlight:

========================
Linux屏幕背光
========================

当黎明或深夜时，使用Linux主机进行开发和运维工作，你会感到屏幕的背光十分刺目，让你双眼酸痛。然而，显示器的内置硬件调整菜单非常原始，调整起来既麻烦又无法快速恢复。这时候，你会想是否可以像Mac主机一样，通过快捷按键来调整屏幕亮度呢？

在Linux系统中，除了硬件厂商直接提供的特定快捷键外，还可以提供过两种软件方式来设置屏幕亮度:

- 通过 :ref:`acpi` 、显卡或者平台驱动，可以将屏幕背光控制输出到 ``/sys/class/backlight`` ，这样就能通过用户侧 ``backlight`` 工具来控制
- 通过 ``setpci`` 可以向显卡寄存器设置值

.. note::

   :ref:`raspberry_pi` 默认没有使用 :ref:`pi_uefi` ，所以无法启用ACPI，也就无法通过ACPI调整显示器背光。这个问题，后续我将在完成 :ref:`pi_uefi_acpi` 转换后再次实践。

硬件接口
===========

ACPI
-------

屏幕背光亮度是同u哦设置LEDs的能源级别实现的，这个能源级别通常使用视频的ACPI内核模块控制。这个模块的接口通过 ``sysfs`` 目录 ``/sys/class/backlight/`` 来提供。

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

参考
=======

- `arch linux wiki: Backlight <https://wiki.archlinux.org/title/backlight>`_
