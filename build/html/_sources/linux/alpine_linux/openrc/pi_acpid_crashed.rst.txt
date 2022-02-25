.. _pi_acpid_crashed:

================================
排查树莓派OpenRC:acpid crashed
================================

我在 :ref:`pi_4` 上部署 :ref:`alpine_linux` ，发现有一个系统服务 ``acpid`` 始终是crashed状态

- 检查服务状态::

   rc-status

显示::

   Runlevel: default
    crond                                                    [  started   ]
    acpid                                                    [  crashed   ]
    ...

- 尝试重启::

   rc-service acpid restart

但是再次检查依然是 ``crashed`` 状态

- 检查日志 ``/var/log/acpid.log`` ::

   acpid: /dev/input/event0: No such file or directory

ACPI和ARM系统SBSA
===================

ACPI传统上只用于 ``x86/x86-64`` 系统，不过现在 ARM 服务器基础系统架构(ARM Server Base System Architecture, SBSA)也加入了这个需求。

在树莓派虽然运行 ``aarch64`` 的64位操作系统，但是需要 :ref:`pi_uefi` 特定的UCFI+ACPI Firmware才能达到ARM的SBBR兼容。

参考
======

- `Problem with acpid on rasberrypi <https://gitlab.alpinelinux.org/alpine/aports/-/issues/12290>`_
