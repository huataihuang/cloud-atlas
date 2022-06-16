.. _archlinux_config_ip:

==============================
arch linux配置IP(静态或动态)
==============================

在arch linux系统中，配置IP地址主要通过:

- ``netctl``
- :ref:`systemd_networkd`

.. note::

   以下案例网络设备命名已经采用了 :ref:`udev_rename_nic` ，所以有线网络接口为 ``eth0`` / 无线网络接口 ``wlan0`` 

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

(可选)对于网络配置，如果识别的网卡命名不是默认约定的 ``eth0`` 和 ``wlan0`` 会带来一些困扰。所以，如果需要可以先采用 :ref:`udev_rename_nic` 。

.. note::

   我在 :ref:`archlinux_on_thinkpad_x220_u_disk` 没有采用 ``netctl`` 而是采用 :ref:`systemd_networkd` ，所以这段只做记录

- 复制配置案例::

   sudo cp /etc/netctl/examples/ethernet-static /etc/netctl/eth0

- 修订 ``/etc/netctl/eth0`` :

.. literalinclude:: archlinux_config_ip/netctl_eth0
   :language: ini
   :caption: /etc/netctl/eth0

- 激活每次自动启动::

   sudo netctl enable eth0

- 最后启动网卡::

   sudo netctl start eth0

- 既然是静态分配IP，我们可以关闭和禁止dhcp服务::

   sudo systemctl stop dhcpcd
   sudo systemctl disable dhcpcd

:ref:`systemd_networkd` 方法
-------------------------------

使用 :ref:`systemd` 的 :ref:`systemd_networkd` 配置静态IP地址的方法更为通用

- 编辑创建一个网络profile: ``/etc/systemd/network/eth0.network`` :

.. literalinclude:: archlinux_config_ip/eth0.network
   :language: ini
   :caption: /etc/systemd/network/eth0.network

参考
=======

- `How To Configure Static And Dynamic IP Address In Arch Linux <https://ostechnix.com/configure-static-dynamic-ip-address-arch-linux/>`_
