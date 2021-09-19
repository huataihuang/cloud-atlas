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

安装firmware(可能)
======================

.. note::

   以前的经验是对于私有软件(驱动)需要安装对应的firmware

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

- 检查Broadcom无线芯片::

   dmesg | grep Broadcom

可以看到::

   [    8.212259 ] b43-phy0: Broadcom 4360 WLAN found (core revision 42)
   [    8.212536 ] Broadcom 43xx driver loaded [ Features: PNLS  ]

- 安装SDK和git::

   apk add alpine-sdk git

- 切换到普通用户，然后将这个用户账号添加到 ``abuild`` 组::

   su - huatai
   sudo addgroup $(whoami) abuild

- 首次build软件包，需要生成一个签名包到key::

   abuild-keygen -a -i

- 下载源代码::

   git clone git://git.alpinelinux.org/aports

- 进入 b43-firmware ::

   cd aports/non-free/b43-firmware

在目录下有一个 ``APKBUILD`` 文件，类似 :ref:`gentoo_linux` 

- 编译软件包::

   abuild -r

编译完成后，在 ``~/packages/non-free/x86_64/`` 目录下有一个 ``b43-firmware-4.150.10.5-r1.apk`` 软件包

- 需要传递一个 ``--allow-untrustedd`` ::

   apk add --allow-untrusted ~/packages/non-free/x86_64/b43-firmware-4.150.10.5-r1.apk

报错::

   (1/1) Installing b43-firmware (4.150.10.5-r1)
   ERROR: Failed to create lib/firmware/b43/a0g0bsinitvals5.fw: No such file or directory
   ERROR: Failed to create lib/firmware/b43/a0g0bsinitvals9.fw: No such file or directory
   ERROR: Failed to create lib/firmware/b43/a0g0initvals5.fw: No such file or directory
   ...

在 `Broadcom wireless package installation <https://dev.alpinelinux.org/~clandmeter/other/forum.alpinelinux.org/forum/networking/broadcom-wireless-package-installation.html>`_ 提出了是需要参考 `How do I write to/make changes to an existing squashfs filesystem? <https://stackoverflow.com/questions/10704353/how-do-i-write-to-make-changes-to-an-existing-squashfs-filesystem>`_ 修订squashfs文件系统。不过，我暂时没有时间实践，等以后有机会再补充。

参考
========

- `Connecting to a wireless access point <https://wiki.alpinelinux.org/wiki/Connecting_to_a_wireless_access_point>`_
- `Broadcom wireless package installation <https://dev.alpinelinux.org/~clandmeter/other/forum.alpinelinux.org/forum/networking/broadcom-wireless-package-installation.html>`_
- `Alpine Linux: Raspberry Pi <https://wiki.alpinelinux.org/wiki/Raspberry_Pi>`_
- `abuild broadcom wireless driver <https://dev.alpinelinux.org/~clandmeter/other/forum.alpinelinux.org/forum/installation/abuild-broadcom-wireless-driver.html>`_
