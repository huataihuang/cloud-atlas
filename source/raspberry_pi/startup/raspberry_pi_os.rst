.. _raspberry_pi_os:

=========================
Raspbery Pi OS(Raspbian)
=========================

Raspberry Pi OS是基于Debain开发的开源操作系统，并且针对 :ref:`pi_hardware` 进行了优化，所以建议在常规树莓派使用场景采用。Raspberry Pi OS提供了超过3万5千个预先编译打包好的易于安装的软件包。

.. note::

   Raspberry Pi OS基于Debian开发，所以继承了Debian社区大量的软件，易于安装维护。从2022年1月开始，Raspberry Pi OS正式发布了64位操作系统，所以现在可以用树莓派官方OS来取代之前我曾经过渡期使用的 :ref:`ubuntu64bit_pi`

下载
==============

从 `Raspberry Pi Operating system images <https://www.raspberrypi.com/software/operating-systems/>`_ 下载官方镜像:

- Raspberry Pi OS: 通用32位系统，可以用于所有树莓派型号，可以在早期 :ref:`pi_1` 和 :ref:`pi_zero` 使用
- Raspberry Pi OS (64-bit): 64为系统，用于 :ref:`pi_3` 及后续更高版本硬件
- Raspberry Pi OS (Legacy): 上一个稳定版本，旧版
- Raspberry Pi OS (Legacy, 64-bit): 上一个稳定版本，旧版，64位系统
- Raspberry Pi Desktop: 似乎是在PC或Mac系统上通过iso镜像文件来制作安装启动盘(我没有实践)

以上不同版本树莓派 Raspberry Pi OS (除Raspberry Pi Desktop以外)分别都有如下分支版本:

- Raspberry Pi OS with desktop 桌面系统
- Raspberry Pi OS with desktop and recommended software 附加推荐软件的桌面系统
- Raspberry Pi OS Lite 仅包含核心操作系统

安装
==========

采用 :ref:`pi_quick_start` 步骤完成初始安装和运行，历代 :ref:`pi_hardware` 操作系统安装方法基本相同，兼容性非常好，所以几乎没有什么难度，只需要制作启动TF卡启动，然后按照交互引导简单配置就能够使用( 如果要使用USB接口存储，可以参考 :ref:`usb_boot_ubuntu_pi_4` ，存储IO性能会有很大提升)

参考
========

- `Raspberry Pi OS <https://www.raspberrypi.com/documentation/computers/os.html>`_
