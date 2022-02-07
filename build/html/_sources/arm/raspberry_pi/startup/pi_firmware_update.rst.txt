.. _pi_firmware_update:

=======================
树莓派firmware升级
=======================

和 :ref:`macos` 相似，树莓派SoC的firmware升级包含在每次操作系统升级中，但是需要注意:

- :ref:`raspbian`
- 默认只升级 ``firmware`` 但不升级 ``eeprom`` (bootloader)

我最初是在 :ref:`usb_boot_ubuntu_pi_4` 时尝试升级firmware，原因是当时 :ref:`pi_4` 还没有提供从USB启动的 ``bootloader`` ，所以需要手工升级 ``eeprom`` pre版本来获得这个能力。不过，随着树莓派系统的不断升级，目前正式版已经不再需要这个hack手段，可以直接通过 ``raspi-config`` 来完成这个启动顺序配置。

.. note::

   firmware是一种特殊软件，用于将操作系统指令转换成硬件能够理解的命令。一个例子是驱动程序，例如Wi-Fi卡驱动

更新firmware是保持操作系统和软件最新的重要一步，影响到安全或者性能。例如，树莓派官方于2021年11月的更新，将 :ref:`pi_4` 的turbo-mode主频从1.5 GHz提高到1.8 GHz ( :ref:`pi_overclock` )

参考
=======

- `Raspberry Pi 4 Firmware Update: All You Need to Know <https://all3dp.com/2/raspberry-pi-4-firmware-update-tutorial/>`_
