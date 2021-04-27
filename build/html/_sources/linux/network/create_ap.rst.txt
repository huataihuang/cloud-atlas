.. _create_ap:

===========================
使用create_ap工具创建软AP
===========================

Linux可以实现软件方式的无线访问节点(software access point)，也称为虚拟路由器(virtual router)或虚拟Wi-Fi，这种方式可以将一台主机的无线网卡转换成一个Wi-Fi access point。

`oblique/create_ap <https://github.com/oblique/create_ap>`_ 是一个脚本帮助快速创建Linux上的无线AP。

.. note::

   目前create_ap项目已经不再维护，建议采用以下两个fork出来的开源项目:

   - `linux-wifi-hotspot <https://github.com/lakinduakash/linux-wifi-hotspot>`_ 聚焦在提供GUI以及一些增强
   - `linux-router <https://github.com/garywill/linux-router>`_ 致力于提供新功能以及增强，并且不限于WiFi。一些有用的功能包括：通过有线网络接口共享Internet，通过使用redsocks提供透明代理共享Internet。

   我的实践:

   - :ref:`linux_wifi_hotspot`
   - :ref:`linux_router`

硬件要求
==========

无线网卡设备必须是一个 ``nl80211`` 兼容的无线设备，这样才能支持 AP operating mode。通过 ``iw list`` 命令可以检查::

   iw list

输出内容中必须包含 ``AP`` 支持::

	Supported interface modes:
		 * IBSS
		 * managed
		 * AP
		 * AP/VLAN
		 * monitor   

单一Wi-Fi设备的无线客户端软件AP
====================================

创建一个软AP和你当前使用的网络连接无关，很多无线设备甚至支持同时作为一个无线"客户端"和无线"AP"。使用这种能力，你可以在现有网络上创建一个软AP作为无线中继器( ``wireless repeater`` )，这样就只需要使用一个无线设备就可以了。这种能力在 ``iw list`` 中可以看到::

	valid interface combinations:
		 * #{ managed } <= 1, #{ AP } <= 1,
		   total <= 2, #channels <= 1, STA/AP BI must match
		 * #{ managed } <= 2,
		   total <= 2, #channels <= 1

这里的限制 ``#channels <= 1`` 表示软件AP必须和Wi-Fi客户端连接在相同频道中。

如果你想要使用 ``capability/feature`` ，例如你的设备只有无线网卡而没有有线的以太网卡，则需要创建两个分离的 ``virtual interface`` ，这种虚拟网络接口是物理设备 ``wlan0`` 的子接口，需要使用各自独立的MAC地址，例如::

   iw dev wlan0 interface add wlan0_sta type managed addr 12:34:56:78:ab:cd
   iw dev wlan0 interface add wlan0_ap  type managed addr 12:34:56:78:ab:ce

这里的随机MAC地址可以使用 ``macchanger`` 来生成。

配置
========

设置一个无线AP的步骤分两部分::

- 设置 ``Wi-Fi链路层`` (Wi-Fi link layer)，这样无线客户端可以和主机软件AP结合起来并交换IP包
- 设置 ``网络配置`` ，这样可以中继

create_ap
-----------

使用 ``create_ap`` 工具可以快速完成无线AP配置，并且支持bridge和NAT模式，能够自动结合 hostapd, dnsmasq 和 iptables 完成AP设置。

- 基本的命令就可以配置一个NAT模式虚拟网络::

   create_ap wlp3s0 enp0s25 MyAccessPoint MyPassPhrase

.. note::

   上述环境中，无线网卡名为 wlp3s0 ，有线网卡名为 enp0s25 ，将自动配置共享无线AP，并通过有线网络连接Internet。

默认的 create_ap 所使用的摹本配置文件是 ``/etc/create_ap.conf`` ，你可以通过以下命令方式修订该配置并运行脚本::

   create_ap --config /etc/create_ap.conf

实践中 ``create_ap --hidden wlp3s0 enp0s25 MyAccessPoint MyPassPhrase`` 可能会有一些配置错误提示，例如::

   ERROR: Maybe your WiFi adapter does not fully support virtual interfaces.
          Try again with --no-virt.

则按照提示再增加 ``--no-virt`` 配置参数。

.. note::

   在运行 ``create_ap`` 命令前，需要确保无线网卡已经激活，但没有被 NetworkManager 接管::

      ip link set wlp3s0 up

   如果没有激活无线网卡，则运行 ``create_ap`` 会提示报错::

      RTNETLINK answers: Operation not possible due to RF-kill

如果再次运行 ``create_ap`` 命令，有可能残留了进程锁文件，导致启动报错::

   ERROR: Failed to initialize lock

解决方法是删除锁::

   rm /tmp/create_ap.all.lock

如果你升级过内核，则可能会出现一个报错::

   iptables v1.8.4 (legacy): unknown option "--to-ports"
   Try `iptables -h' or 'iptables --help' for more information.

需要重启一次系统来解决。

综上，还可以添加 ``--hidden`` 设置隐藏但SSID::

   create_ap --hidden --no-virt wlp3s0 enp0s25 MyAccessPoint MyPassPhrase

如果成功，则会提示如下::

   PID: 3186
   Network Manager found, set wlp3s0 as unmanaged device... DONE
   Access Point's SSID is hidden!
   Sharing Internet using method: nat
   hostapd command-line interface: hostapd_cli -p /tmp/create_ap.wlp3s0.conf.VUfVqfZx/hostapd_ctrl
   Configuration file: /tmp/create_ap.wlp3s0.conf.VUfVqfZx/hostapd.conf
   WARN: Low entropy detected. We recommend you to install `haveged'
   Using interface wlp3s0 with hwaddr 08:11:96:8a:e2:b4 and ssid "MyAccessPoint"
   wlp3s0: interface state UNINITIALIZED->ENABLED
   wlp3s0: AP-ENABLED`

则在 ``/tmp/create_ap.wlp3s0.conf.VUfVqfZx/`` 目录下有一系列配置用于AP运行。

.. note::

   这也是我 :ref:`android_10_pixel_xl` 时解决首次启动Android强制连接Google服务的方法。

   第一次实践发现hostapd分配dhcp地址有问题，这个可能和我环境部署了比较复杂的虚拟化以及 :ref:`anbox` 有关。第二次实践 :ref:`jetson_soft_ap` 则工作正常。

下一步
=========

我准备下次实践的时候不仅要解决DHCP分配地址问题，而且需要结合 FreeRADIUS 实现一个 `arch Linux 环境WPA2 Enterprise 部署 <https://wiki.archlinux.org/index.php/WPA2_Enterprise>`_ 。

参考
=======

- `Software access point <https://wiki.archlinux.org/index.php/software_access_point>`_
