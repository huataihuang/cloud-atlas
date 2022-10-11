.. _freebsd_wifi:

====================
FreeBSD无线网络
====================

.. note::

   本文实践在 :ref:`mbp15_late_2013` 完成，使用的无线网卡芯片是 Broadcom

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

- 在加载内核模块完成后，就可以通过以下命令创建无线网卡设备::

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

待续...

参考
======

- `First FreeBSD experience: something with Wi-Fi and Apple hardware <https://streof.github.io/freebsd-wifi-mac/>`_
- `FreeBSD Kernel Interfaces Manual: BWN(4) <https://www.freebsd.org/cgi/man.cgi?bwn(4)>`_
- `FreeBSD Broadcom Wi-Fi Improvements <https://landonf.org/code/freebsd/Broadcom_WiFi_Improvements.20180122.html>`_
- `FreeBSD cannot use WiFi with BCM4360 on MacBook Air <https://unix.stackexchange.com/questions/367591/freebsd-cannot-use-wifi-with-bcm4360-on-macbook-air>`_
- `I just want my WiFi working! <https://wiki.freebsd.org/WiFi/FAQ>`_
- `bhnd(4) - Broadcom Home Networking Division interconnect bus driver <https://wiki.freebsd.org/dev/bhnd%284%29>`_
