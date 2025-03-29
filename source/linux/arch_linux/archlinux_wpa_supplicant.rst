.. _archlinux_wpa_supplicant:

==========================================
arch linux使用wpa_supplicant连接无线网络
==========================================

无线网卡驱动
==============

我使用两种arch linux发行版:

- :ref:`asahi_linux` : 内置了 :ref:`apple_silicon_m1_pro` MacBook Pro内置的无线网卡驱动，所以可以直接识别出 ``wlan0``
- 标准版 arch linux : 在 MacBook Pro 2013 later 上，由于Broadcom的授权限制默认不提供Broadcom BCM4360 802.11ac无线网卡驱动，需要独立安装 ``broadcom-wl-dkms`` 软件包

安装 ``broadcom-wl-dkms``
---------------------------

在arch linux上编译安装 :ref:`dkms` 内核模块都需要先安装操作系统内核对应头文件，否则会报错类似 ``ERROR: Missing sys kernel headers for module broadcom-wl...``

- 和 :ref:`install_nvidia_linux_driver` 的 :ref:`install_cuda_prepare` 工作相同，安装正确的内核头文件和开发工具包::

   pacman -S linux-headers

- 安装驱动::

   pacman -S broadcom-wl-dkms

wpa_supplicant基础配置
========================

- 创建 ``wpa_supplicant`` 的配置文件:

.. literalinclude:: archlinux_wpa_supplicant/wpa_passphrase
   :language: bash

.. note::

   wap_supplicant配置文件命名为 ``/etc/wpa_supplicant/wpa_supplicant-interface.conf`` 可以方便后面结合 :ref:`systemd_networkd` 启动对应的无线网卡

   对于5G的无线网络，需要配置 ``country code``

   对于隐藏AP，需要添加 ``ap_scan``

- 激活对应无线网卡的服务，并且激活dhcpcd (DHCP客户端):

.. literalinclude:: archlinux_wpa_supplicant/systemctl_enable_wpa_passphrase_dhcpcd
   :language: bash

- 已经配置完成，可以重启主机生效或者直接启动服务:

.. literalinclude:: archlinux_wpa_supplicant/systemctl_start_wpa_passphrase_dhcpcd
   :language: bash

.. _wpa_supplicant_static_ip:

wpa_supplicant分配静态IP地址
=============================

在 :ref:`arch_linux` 系统中， :ref:`wpa_supplicant` 完成认证连接上无线网络之后，将使用 ``dhcpcd`` 分配地址，所以可以采用 :ref:`dhcpcd_static_ip` 配置方法，修订 ``/etc/dhcpcd.conf`` 配置添加如下内容:

.. literalinclude:: ../../raspberry_pi/network/raspbian_static_ip/wlan_dhcpcd.conf
   :caption: 无线网络使用dhcpcd分配静态IP地址

参考
=======

- `archlinux: wpa_supplicant <https://wiki.archlinux.org/title/Wpa_supplicant>`_
- `archlinux: Broadcom wireless <https://wiki.archlinux.org/title/broadcom_wireless>`_
