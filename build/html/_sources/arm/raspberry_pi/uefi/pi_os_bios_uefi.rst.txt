.. _pi_os_bios_uefi:

==============================
Raspberry Pi OS转换BIOS到UEFI
==============================

我在 :ref:`alpine_convert_bios_uefi` 之前，首先尝试标准 :ref:`raspberry_pi_os` 环境转换BIOS到UEFI运行环境。这个步骤是为了实现ARM规范 服务器基础启动要求(Server Base Boot Requirement, `SBBR <https://developer.arm.com/architectures/platform-design/server-systems#faq3>`_ )以便能够在树莓派上运行 ``acpid`` 实现服务器硬件管理。

实践工作在 :ref:`pi_400` 上完成，也就是 :ref:`edge_cloud` 中作为 ``x-adm`` 管理桌面的主机。已经安装了最新的 :ref:`raspberry_pi_os` ，不过最初安装的模式还是传统的BIOS模式，本文实践采用 `Making Pi ServerReady <https://rpi4-uefi.dev/>`_ 提供的 `Raspberry Pi 4 UEFI Firmware Images <https://github.com/pftf/RPi4>`_ ，转换操作系统为UEFI模式。

实践
======

参考
======

- `Raspberry Pi 4 UEFI+ACPI Firmware Aims to Make the Board SBBR-Compliant <https://www.cnx-software.com/2020/02/18/raspberry-pi-4-uefiacpi-firmware-aims-to-make-the-board-sbbr-compliant/>`_
- `Making Pi ServerReady <https://rpi4-uefi.dev/>`_
