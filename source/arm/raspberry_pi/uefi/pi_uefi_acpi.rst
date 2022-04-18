.. _pi_uefi_acpi:

==================
树莓派UEFI+ACPI
==================

我在 :ref:`edge_cloud` 上部署 :ref:`alpine_linux` ， :ref:`pi_acpid_crashed` 发现，常规树莓派firmware并没有支持ACPI，无法实现ARM的Server Base Boot Requirement (SBBR)规范:

- 由于系统没有 ``/dev/input/event0`` 设备而导致 ``acpid`` 服务 ``crashed`` 。
- 缺少 ``/sys/class/backlight/`` 设备目录及控制文件，无法通过 ``ACPI`` 接口调整 :ref:`linux_backlight`

ARM SBSA和SBBR
=================

随着ARM进入服务器市场，ARM需要实现不需要修改或hack系统就能够启动标准操作系统，就像x86服务器上启动操作系统一样。所以，在2014年，ARM公司发布了 `Server Base System Architecture (SBSA) <https://www.cnx-software.com/2014/01/31/arm-unveils-system-base-architecture-specification-to-standardize-arm-based-servers/>`_ 规范来帮助所有单一操作系统镜像(single OS image)能够运行在所有ARMv8-A服务器上。

随后，ARM发布了服务器基础启动要求(Server Base Boot Requirement, `SBBR <https://developer.arm.com/architectures/platform-design/server-systems#faq3>`_ )规格来描述服务器的标准firmware接口，包括了 UEFI, ACPI 和 SMBIOS 工业标准，并且在 2018 年引入了ARM服务器的ARM服务器就绪认证程序( `Arm Serverready compliance program <https://www.cnx-software.com/2018/10/17/arm-serverready-compliance-program-arm-servers/>`_ )。

树莓派UEFI firmware
====================

上述规范都是面向ARM服务器，现在开发者也在实现将SBBR兼容引入ARM个人电脑，并且有一个 `Making Pi ServerReady <https://rpi4-uefi.dev/>`_ 项目专注于 :ref:`pi_4` SBBR-compliant (UEFI+ACPI) AArch64 firmware 开发，为树莓派进入服务器领域提供支持。

这个树莓派UEFI firmware是从 `64位 Tiano Core UEFI firmware <https://github.com/tianocore/edk2-platforms/tree/master/Platform/RaspberryPi/RPi4>`_ port到 :ref:`pi_4` 的，目前持续活跃开发。不过，需要注意， :ref:`pi_4` UEFI firmware依然是试验行的，所以有可能还存在bug

:ref:`pi_3` 也有对应的 `64-bit Tiano Core UEFI firmware for the Raspberry Pi 3B <https://github.com/tianocore/edk2-platforms/tree/master/Platform/RaspberryPi/RPi3>`_ 。`

参考
=====

- `Raspberry Pi 4 UEFI+ACPI Firmware Aims to Make the Board SBBR-Compliant <https://www.cnx-software.com/2020/02/18/raspberry-pi-4-uefiacpi-firmware-aims-to-make-the-board-sbbr-compliant/>`_
- `Making Pi ServerReady <https://rpi4-uefi.dev/>`_
