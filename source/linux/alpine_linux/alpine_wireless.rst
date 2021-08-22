.. _alpine_wireless:

======================
设置Alpine Linux无线
======================

- 安装pciutils::

   apk add pciutils

检查网卡设别::

   lspci | grep -i network

显示::

   03:00.0 Network controller: Broadcom Inc. and subsidiaries BCM4360 802.11ac Wireless Network Adapter (rev 03)

- 安装无线配置软件::

   apk add wireless-tools wpa_supplicant

- 检查无线网卡::

   ip link

如果没有看到 ``wlan0`` 设备，则说明需要安装无线网卡的firmware::

   apk add linux-firmware

`alpine linux linux-firmware <https://pkgs.alpinelinux.org/package/edge/main/x86/linux-firmware>`_ 包含了90+以上驱动fireware，其中就包含了 ``linux-firmware-brcm`` (但是我初步验证似乎没有成功，所以还是按照官方文档从源代码编译安装Broadcom firmware)

完整安装 ``linux-firmware`` 非常缓慢，所以建议只安装需要的firmware::

   apk add linux-firmware-brcm

如果不需要任何firmware，则安装 ``linux-firmware-none`` ，如果不知道需要安装哪个firmware，则::

   dmesg | grep firmware

查看需要安装信息

编译驱动
===========

官方文档 `Connecting to a wireless access point <https://wiki.alpinelinux.org/wiki/Connecting_to_a_wireless_access_point>`_ 已经说明了Broadcom芯片需要手工编译安装驱动

参考
========

- `Connecting to a wireless access point <https://wiki.alpinelinux.org/wiki/Connecting_to_a_wireless_access_point>`_
- `Broadcom wireless package installation <https://dev.alpinelinux.org/~clandmeter/other/forum.alpinelinux.org/forum/networking/broadcom-wireless-package-installation.html>`_
- `Alpine Linux: Raspberry Pi <https://wiki.alpinelinux.org/wiki/Raspberry_Pi>`_
- `abuild broadcom wireless driver <https://dev.alpinelinux.org/~clandmeter/other/forum.alpinelinux.org/forum/installation/abuild-broadcom-wireless-driver.html>`_