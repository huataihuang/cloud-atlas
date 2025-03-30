.. _freebsd_wifi:

====================================
FreeBSD无线网络(失败过程记录归档)
====================================

.. warning::

   之前尝试安装FreeBSD驱动没有成功，我现在review了一下当时的操作，感觉还是在加载内核配置上存在问题。最近看到 `FreeBSD从入门到跑路: 第 14.2 节 WiFi >> 博通（broadcom）网卡驱动 <https://book.bsdcn.org/di-14-zhang-wang-luo-guan-li/di-14.2-jie-wifi#bo-tong-broadcom-wang-ka-qu-dong>`_ 介绍了如何安装驱动方法。我又仔细看了一下 `FreeBSD Broadcom Wi-Fi Improvements <https://landonf.org/code/freebsd/Broadcom_WiFi_Improvements.20180122.html>`_ 最后一段，提到了Retian MacBook Pro 2016，其中使用的 Broadcom FullMAC设备(BCM4350)不能被 ``bwn`` 驱动支持。但是， ``bhnd`` 驱动是从 Broadcom 的 ISC-licensed ``brcmfmac`` Linux驱动移植过来，似乎可能会支持。

   Anyway，我可能会重新做一次尝试 :ref:`freebsd_broadcom_wifi_bcm43602` 

以下归档
=============

.. note::

   本文实践在 :ref:`mbp15_late_2013` 进行，使用的无线网卡芯片是 Broadcom BCM4360 。这个无线芯片可以在Linux上工作，但是FreeBSD目前无法支持。我做了花了一个晚上时间折腾没有解决，由于改为使用 :ref:`apple_silicon_m1_pro` (公司配备)，所以暂缓探索。

检查硬件
=========

- 执行 ``pciconf`` 命令检查硬件::

   pciconf -lv

显示::

   none1@pci0:3:0:0:	class=0x028000 rev=0x03 hdr=0x00 vendor=0x14e4 device=0x43a0 subvendor=0x106b subdevice=0x0134
       vendor     = 'Broadcom Inc. and subsidiaries'
       device     = 'BCM4360 802.11ac Wireless Network Adapter'
       class      = network

``bwn`` 驱动
=============

``bwn`` 无线网络驱动支持Broadcom BCM43xx ，并且支持 ``station`` 和 ``monitor`` 模式操作。这个 ``bwn`` 驱动要求在其工作前首先加载firmware。所以需要先编译安装 ``ports/net/bwn-firmware-kmod`` 这个port。

``bwn`` 驱动支持的 Broadcom BCM43xx 无线设备包括:

.. csv-table:: bwn支持的Broadcom BCM43xx 无线设备列表
   :file: freebsd_wifi/bwn_bcm43xx.csv
   :widths: 40, 30, 15, 15
   :header-rows: 1

要将这个 ``bwn`` 驱动编译进你和，则要在内核配置文件中加入以下行::

   device bwn
   device bhnd
   device bhndb
   device bhndb_pci
   device bcma
   device siba
   device gpio
   device wlan
   device wlan_amrr
   device firmware 

要在启动时加载 ``bwn`` 驱动模块，则在 ``loader.conf`` 中添加::

   if_bwn_load="YES"

编译安装bwn firmware
-------------------------

- 执行 :ref:`freebsd_ports` 方式编译安装firmware::

   cd /usr/ports/net/bwn-firmware-kmod
   make
   make install clean

这里如果系统没有安装 :ref:`freebsd_kernel_source` 就会出现以下报错::

   make[1]: "/usr/share/mk/bsd.sysdir.mk" line 15: Unable to locate the kernel source tree. Set SYSDIR to override.

   make[1]: stopped in /usr/ports/net/bwn-firmware-kmod/work/bwn-firmware-kmod-0.1.2/bg/v4
   *** Error code 1

则先安装 :ref:`freebsd_kernel_source` 然后再次执行 ``make``

- 加载内核模块::

   sudo kldload if_bwn 
   sudo kldload bwn_v4_ucode 
   sudo kldload bwn_v4_lp_ucode

对于要在系统启动时自动加载上述内核模块，则编辑 ``/boot/bootloader.conf`` 添加::

   if_bwn_load="YES"
   bwn_v4_ucode_load="YES"
   bwn_v4_lp_ucode_load="YES"

- 在加载内核模块完成后，就可以通过以下命令创建无线网卡设备::

   ifconfig wlan0 create wlandev bwn0

报错::

   ifconfig: SIOCIFCREATE2: Device not configured

原因是前面加载无线驱动和firmware并没有检测到 ``/dev/bwn0`` 设备。

.. warning::

   很不幸，FreeBSD今天还是没有支持 BCM4360 ，从 `Macbook Air 2017 : Need Help With Proprietary Firmware/Driver <https://forums.freebsd.org/threads/macbook-air-2017-need-help-with-proprietary-firmware-driver.81605/>`_ 可以看到实际上并没有解决驱动MacBook Air 2017内置的BCM4360设备。这个讨论最后建议使用USB接口的外接无线网卡，或者使用类似 `PQI Air Pen Express Wireless Router <https://www.amazon.co.uk/PQI-Air-Express-Wireless-Router/dp/B00BNAST1I>`_ 这样的设备。

   不过，也提出了一个思路: 使用手机的USB Tethering功能，将手机的无线网卡模拟成以太网卡，只要将手机USB连接以后，激活 ``USB tethring`` ，此时在FreeBSD中就会看到一个USB无线网卡设备，就能够直接使用没有任何障碍: :ref:`freebsd_usb_tethering_wifi`

   参考 `First FreeBSD experience: something with Wi-Fi and Apple hardware <https://streof.github.io/freebsd-wifi-mac/>`_ 详细说明了如何编译安装firmware，步骤和我上文相似，但是最终也没有解决BCM43602设备驱动

以下命令没有执行，原因是上文 ``bwn`` 驱动并不支持 ``BCM4360`` ，不过记录备用::

   sudo ifconfig wlan0 up # Laptop WiFi LED light should turn on
   sudo ifconfig wlan0 scan # You should see your wireless router SSID
   sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant.conf 
   sudo ifconfig wlan0 list sta 
   sudo dhclient wlan0 

.. warning::

   我这里失败，加载驱动以及firmware之后并没有看到网卡设备

   我仔细核对 `FreeBSD Broadcom Wi-Fi Improvements <https://landonf.org/code/freebsd/Broadcom_WiFi_Improvements.20180122.html>`_ ``bwn`` 说明，原来支持的 ``BCM43xx`` 并没有包括我的 MacBook Pro 的无线网卡芯片 ``BCM4360`` 。实际上，应该使用 ``bhnd`` 驱动...

   重新来过

``bhnd`` 驱动安装
==================

要加载驱动模块，在 ``/boot/loader.conf`` 中添加::

   bhnd_load="YES"

我参考 `BCM4331 802.11n seems tantalisingly close on mid-2011 Mac mini, using bhnd and if_bwn_pci.ko on FreeBSD 11.2-BETA1 <https://forums.freebsd.org/threads/bcm4331-802-11n-seems-tantalisingly-close-on-mid-2011-mac-mini-using-bhnd-and-if_bwn_pci-ko-on-freebsd-11-2-beta1.65927/>`_ ，配置 ``/boot/loader.conf`` ::

   bhnd_load="YES"
   bwn_v4_ucode="YES"
   bwn_v4_n_ucode="YES"
   #if_bwn_pci_load="YES"
   if_bwn_load="YES"
   wlan_wep_load="YES"
   wlan_ccmp_load="YES"
   wlan_tkip_load="YES"

但是，似乎模块都加载了也看不到设备

.. note::

   由于拿到了公司配备的 :ref:`apple_silicon_m1_pro` ，暂时没有使用FreeBSD作为全功能桌面的个人需求，所以暂缓实践。后续有时间和机会再来尝试。

参考
======

- `First FreeBSD experience: something with Wi-Fi and Apple hardware <https://streof.github.io/freebsd-wifi-mac/>`_
- `FreeBSD Kernel Interfaces Manual: BWN(4) <https://www.freebsd.org/cgi/man.cgi?bwn(4)>`_
- `FreeBSD Broadcom Wi-Fi Improvements <https://landonf.org/code/freebsd/Broadcom_WiFi_Improvements.20180122.html>`_
- `FreeBSD cannot use WiFi with BCM4360 on MacBook Air <https://unix.stackexchange.com/questions/367591/freebsd-cannot-use-wifi-with-bcm4360-on-macbook-air>`_
- `I just want my WiFi working! <https://wiki.freebsd.org/WiFi/FAQ>`_
- `bhnd(4) - Broadcom Home Networking Division interconnect bus driver <https://wiki.freebsd.org/dev/bhnd%284%29>`_
