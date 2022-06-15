.. _archlinux_config_ip:

==============================
arch linux配置IP(静态或动态)
==============================

在arch linux系统中，配置IP地址主要通过:

- ``netctl``
- :ref:`systemd_networkd`

配置静态IP
==============

``netctl`` 方法
-------------------

``netctl`` 是用于控制systemd服务网络管理器的命令行工具，如果已经安装了 ``netctl`` 则有一些案例位于 ``/etc/netctl/examples/`` 目录下:

- ``ethernet-dhcp``
- ``ethernet-static``

首先通过 ``ip link`` 命令获得主机网卡接口名。在 :ref:`thinkpad_x220` 会显示如下:

  - Intel 82579LM 千兆有线网卡: ``enp0s25``
  - Intel Advanced-N 6205无线网卡: ``wlp3s0``

对于网络配置，如果识别的网卡命名不是默认约定的 ``eth0`` 和 ``wlan0`` 会带来一些困扰。所以，建议首先采用 :ref:



参考
=======

- `How To Configure Static And Dynamic IP Address In Arch Linux <https://ostechnix.com/configure-static-dynamic-ip-address-arch-linux/>`_
