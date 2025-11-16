.. _alpine_wireless_broadcom-wl:

=======================================
设置Alpine Linux无线: ``broadcom-wl``
=======================================

.. note::

   在 :ref:`mbp15_late_2013` 和 :ref:`mba13_early_2014` 上安装Alpine Linux时，默认系统没有识别出Broadcom无线网卡:

   - Broadcom ``BCM4360`` 使用 **wl** 芯片，需要使用 ``broadcom-wl`` 驱动，该驱动是non-free，默认没有包含在仓库中
   - 需要使用源代码自行编译 ``broadcom-wl`` 驱动来安装

   本文重点记录如何在Alpine Linux编译 ``broadcom-wl`` 驱动来支持 Broadcom ``BCM4360``

   :ref:`pi_3` 上安装Alpine Linux非常顺利能够识别无线网卡，所以配置无线记录在 :ref:`alpine_wireless`

- 安装pciutils::

   apk add pciutils

检查网卡设别::

   lspci | grep -i network

显示::

   03:00.0 Network controller: Broadcom Inc. and subsidiaries BCM4360 802.11ac Wireless Network Adapter (rev 03)

**wl** 驱动编译
==================

- 安装编译环境:

.. literalinclude:: alpine_wireless_broadcom-wl/build_env
   :caption: 安装编译环境

- 下载驱动源代码仓库:

.. literalinclude:: alpine_wireless_broadcom-wl/clone_wl_source
   :caption: 下载 ``broadcom-wl`` 源代码

- 编译安装:

.. literalinclude:: alpine_wireless_broadcom-wl/build_wl_source
   :caption: 编译 ``broadcom-wl``

- **重要** 必须屏蔽掉冲突内核模块，否则系统会加载错误模块并导致 ``wlan0`` 不可见 

.. literalinclude:: alpine_wireless_broadcom-wl/blacklist.conf_fixed
   :caption: 修订 ``/etc/modprobe.d/blacklist.conf``

问题排查
-----------

我在执行 ``make`` 时遇到报错:

.. literalinclude:: alpine_wireless_broadcom-wl/unaligned.h_not_found
   :caption: 缺少 ``asm/unaligned.h``
   :emphasize-lines: 7

我检查了 ``linux-headers`` 包含了 :

.. literalinclude:: alpine_wireless_broadcom-wl/unaligned.h_src
   :caption: 内核头文件 unaligned.

google AI提示是较新的内核更改了头文件位置，从 ``asm/unaligned.h`` 移动到了 ``linux/unaligned.h`` ，所以修改 ``src/wl/sys/wl_linux.c`` 然后重新编译即可

但是我发现重启操作系统，并且确认 ``lsmod | grep wl`` 已经看到了如下内核加载:

.. literalinclude:: alpine_wireless_broadcom-wl/lsmod_wl
   :caption: 内核模块加载

检查系统日志 ``dmesg`` :

.. literalinclude:: alpine_wireless_broadcom-wl/dmesg_wifi
   :caption: 检查系统日志
   :emphasize-lines: 2,3

奇怪，怎么针对 ``BCM4360`` 加载了 ``b43`` 驱动?加载失败

尝试修改 ``/etc/modprobe.d/blacklist.conf`` 添加阻断 ``b43`` :

.. literalinclude:: alpine_wireless_broadcom-wl/blacklist.conf
   :caption: 阻断 ``b43`` 加载

但是重启后还是没有识别出 ``wlan0`` 

检查 ``dmesg`` 日志，甚至没有看到 ``broadcom`` 相关信息

我发现一个奇怪的现象， ``lspci`` 显示 ``BCM4360`` 加载的内核模块是 ``bcma-pci-bridge`` :

.. literalinclude:: alpine_wireless_broadcom-wl/lspci_bcm4360
   :caption: 使用 ``lspci -vv -s 03:00.0`` 显示 ``BCM4360`` 使用的驱动是 ``bcma-pci-bridge``
   :emphasize-lines: 7

- 补充安装firmware(似乎应该先安装?):

.. literalinclude:: alpine_wireless_broadcom-wl/install_firmware
   :caption: 安装firmware-brcm

但是没有解决问题

仔细看了一下 `GitHub: antoineco/broadcom-wl <https://github.com/antoineco/broadcom-wl>`_ ，原来 ``wl`` 模块和以下内核模块不兼容:

.. literalinclude:: alpine_wireless_broadcom-wl/incompatible_modules
   :caption: 不兼容 ``wl`` 的冲突模块

- 解决了: 修订 ``/etc/modprobe.d/blacklist.conf`` 添加:

.. literalinclude:: alpine_wireless_broadcom-wl/blacklist.conf_fixed
   :caption: 修订 ``/etc/modprobe.d/blacklist.conf``

然后重启系统就能够正常看到 ``wlan0`` 无线网卡了
 

``akms`` 安装wl驱动(参考)
===========================

.. warning::

   我尝试本段落在安装编译dkms时候没有成功，因为最终上文的手工编译安装 ``wl.ko`` 成功，所以放弃本段，仅记录参考

`Broadcom wl driver for alpine linux <https://codeberg.org/NeYurii/broadcom-wl-alpine>`_ 采用了 ``akms`` 来编译安装apline linux的dkms

- 按照 `Setting up the build environment on HDD <https://wiki.alpinelinux.org/wiki/Setting_up_the_build_environment_on_HDD>`_ 设置好编译环境
- 获取代码仓库:

.. literalinclude:: alpine_wireless_broadcom-wl/git_broadcom-wl-alpine
   :caption: 获取源代码

- 编译软件包

.. literalinclude:: alpine_wireless_broadcom-wl/abuild
   :caption: 编译安装包

- 编译后的软件包位于 ``~/packages`` 目录，通过 ``doas apk add ./broadcom-wl-6.30.223.271-r_.apk`` 安装，实际安装过程会有一个 ``dkms`` 内核编译，不过我的实践在ibianyi过程失败，遂放弃...

无线安装配置
=============

- 安装无线配置软件::

   apk add wireless-tools wpa_supplicant

- 检查无线网卡::

   ip link

遗留问题
----------

源代码安装会执行 ``akms`` 配置，后续内核升级会自动出发 ``wl`` 内核模块编译，但是实践发现 ``akms`` 触发的内核模块编译会出错:

.. literalinclude:: alpine_wireless_broadcom-wl/akms_error
   :caption: ``akms`` 编译 ``wl`` 内核模块报错

这个 ``wlc_hybrid.o_shipped`` 是 Broadcom STA wireless driver软件包提供的私有文件，我发现我的系统中有2个位置包含了这个大约 ``7.0M`` 大小的文件:

.. literalinclude:: alpine_wireless_broadcom-wl/wlc_hybrid.o_shipped
   :caption: 系统中现有的 ``wlc_hybrid.o_shipped``

而且 ``/home/admin/broadcom-wl/lib/`` 目录下就只有这一个文件和LICENSE.txt，所以我直接复制到缺乏文件的 ``akms`` 目录(该目录下没有 ``lib`` 目录):

.. literalinclude:: alpine_wireless_broadcom-wl/cp_wlc_hybrid.o_shipped
   :caption: 复制 ``wlc_hybrid.o_shipped``



.. warning::

   以下内容为早期探索，实际上是Broadcom ``b43`` 编译安装步骤，和 ``broadcom-wl`` 不同，仅供参考

安装 ``b43`` firmware
======================

.. note::

   这段不需要了，因为 ``b43`` 源代码包含firmware部分，可以通过源代码安装firmware，见下文

如果没有看到 ``wlan0`` 设备，则说明需要安装无线网卡的firmware::

   apk add linux-firmware

`alpine linux linux-firmware <https://pkgs.alpinelinux.org/package/edge/main/x86/linux-firmware>`_ 包含了90+以上驱动fireware，其中就包含了 ``linux-firmware-brcm`` (我可能搞错firmware软件包了 ``linux-firmware-brcm`` 是用于比较陈旧的braodcom芯片，另外从源代码编译 ``broadcom-wl`` 驱动包会自动处理获取和安装需要的firmware)

完整安装 ``linux-firmware`` 非常缓慢，所以建议只安装需要的firmware::

   apk add linux-firmware-brcm

如果不需要任何firmware，则安装 ``linux-firmware-none`` ，如果不知道需要安装哪个firmware，则::

   dmesg | grep firmware

查看需要安装信息

编译b43驱动
===============

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

- `Alpine Linux wiki: Wi-Fi <https://wiki.alpinelinux.org/wiki/Wi-Fi>`_
- `Connecting to a wireless access point <https://wiki.alpinelinux.org/wiki/Connecting_to_a_wireless_access_point>`_
- `Broadcom wireless package installation <https://dev.alpinelinux.org/~clandmeter/other/forum.alpinelinux.org/forum/networking/broadcom-wireless-package-installation.html>`_
- `Alpine Linux: Raspberry Pi <https://wiki.alpinelinux.org/wiki/Raspberry_Pi>`_
- `abuild broadcom wireless driver <https://dev.alpinelinux.org/~clandmeter/other/forum.alpinelinux.org/forum/installation/abuild-broadcom-wireless-driver.html>`_
