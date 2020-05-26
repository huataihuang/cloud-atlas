.. _jetson_nano_startup:

======================
Jetson Nano快速起步
======================

NVIDIA :ref:`jetson_nano` Developer Kit是一个小型AI计算机，面向创客、学习者和开发者。使用这个mini设备，可以构建AI应用，超酷的AI机器人，甚至更多的 `Jetson 社区项目 <https://developer.nvidia.com/embedded/community/jetson-projects>`_ 。

下载和准备启动
=================

从 `Jetson Download Center <https://developer.nvidia.com/embedded/downloads>`_ 下载 ``Jetson Nano Developer Kit SD Card Image`` ，然后使用如下命令刻录到SD Card::

   unzip nv-jetson-nano-sd-card-image-r32.3.1.zip
   sudo dd if=sd-blob-b01.img of=/dev/rdisk2 bs=100m

电源跳线
===========

Jetson Nano有3种供电方式：

- 通过Micro-USB接口供电：这种USB供电可以提供 ``5V⎓2A`` 电力，通常对于不带附件的方式已经足够电力。可以很方便移动使用。

- 独立外接电源： ``5V⎓4A`` 适合带动周边附件，例如，将Jetson Nano连接外接磁盘设备

.. note::

   主板上 J48 跳线是用来切换外接电源还是Micro-USB供电。默认是使用Micro-USB供电(跳线没有使用)，如果要使用外接电源，务必将该跳线连接上。

初始化
========

NVIDIA Jetson Nano首次启动速度比较慢，应该是有很多初始化操作在进行。登陆界面是Gnome 3，所以图形界面比较沉重，甚至我觉得在ARM处理器的4G内存规格下，运行这么复杂的图形桌面实在是浪费了系统资源。

.. note::

   后面我准备改为轻量级桌面，例如Xfce4。

登陆初始化提供了选择键盘、时区以及初始账号功能，并且提供了通过网络连接Internet进行更新的选项。如果设备安装了无线网卡，则会提示设置连接WiFi。建议连接网络进行更新。

我的初始设置比较简单，就是将有线网卡设置为固定IP地址 ``192.168.6.10`` ，这样我就可以通过笔记本的有线网络连接到Jetson系统中，并进行远程操作。这样可以不需要连接显示器。

无线网络
==========

Jetson Nano主板没有集成无线网卡，不过，主板m2接口可以安装笔记本通用的无线网卡。我选购的是Intel 8265AC NGW无线网卡，同时集成了蓝牙 4.2。

安装 Intel Wireless-AC8265无线模块 之后，使用 ``lspci`` 命令检查可以看到无线网络设备::

   01:00.0 Network controller: Intel Corporation Wireless 8265 / 8275 (rev 78)

NVIDIA的Jetson Nano官方镜像是基于Ubuntu 18.04.3 LT构建::

   lsb_release -a

默认已经激活使用了NetworkManager: ``systemctl status NetworkManager``

所以，采用 ``nmcli`` 命令可以配置无线网络::

   sudo nmcli device wifi list

- 增加wifi类型连接，连接到名为 ``HOME`` 的AP上（配置设置成名为 ``MYHOME`` ）::

   nmcli con add con-name MYHOME ifname wlan0 type wifi ssid HOME \
   wifi-sec.key-mgmt wpa-psk wifi-sec.psk MYPASSWORD

- 指定配置 ``MYHOME`` 进行连接::

   nmcli con up MYHOME

.. note::

   详细配置可参考 :ref:`set_ubuntu_wifi`

蓝牙
=======

- 安装蓝牙管理工具::

   apt install bluetools blueman

- 然后启动蓝牙服务::

   systemctl start bluetooth

在 :ref:`jetson_xfce4` 中可以使用blueman图形管理工具直接管理蓝牙设备。

初始设置
===========

- 修改 ``/etc/sudoers`` 将个人账号所在的 ``sudo`` 组设置为无需密码::

   # Allow members of group sudo to execute any command
   #%sudo  ALL=(ALL:ALL) ALL
   %sudo   ALL=(ALL:ALL) NOPASSWD:ALL

软件更新
===========

为了能够更好使用Jetson Nano，建议经常更新系统保持和官方软件版本同步。

.. note::

   在国内访问NVIDIA的软件仓库非常缓慢，甚至无法连接。不过，在墙内现在VPN访问阻塞得非常严重，所以我采用 :ref:`linux_tether_vpn` 方式来加速软件更新。

- 升级系统::

   sudo apt update
   sudo apt upgrade

- 清理掉不需要的软件包::

   sudo apt autoremove

瘦身
======

NVIDIA Jetson nano的官方发行版默认安装了实际上对于我平时使用并没有用处的Office软件，所以我准备清理掉不需要的软件包::

   sudo apt remove --purge libreoffice* -y
   sudo apt remove --purge thunderbird* -y
   sudo apt-get clean -y
   sudo apt autoremove -y
   sudo apt-get update

安装必要工具软件::

   sudo apt install curl screen nmon machager lsof dnsmasq
   sudo apt install xfce4 xfce4-terminal fcitx fcitx-sunpinyin
   sudo apt install bluez-tools blueman
   sudo apt install synergy keepassx

远程访问
===========

虽然Jetson nano可以通过直接连接键盘鼠标和显示器进行操作，但是我更希望将这个设备作为远程访问的的边缘AI设备。所以， :ref:`jetson_remote` 可以方便我们以图形界面方式使用。

.. note::

   如果你把Jetson Nano作为桌面系统使用，基本上轻量级的使用没有任何问题。主要的限制是磁盘IO，如果没有快速的TF卡支持，或者通过外接SSD磁盘运行系统，日常使用中IO Wait会导致系统卡顿。但是，只要你能够使用快速的存储系统，则Jetson作为个人桌面系统完全没有压力。

参考
======

- `Getting Started With Jetson Nano Developer Kit <https://developer.nvidia.com/embedded/learn/get-started-jetson-nano-devkit>`_
- `Jetson Nano Developer Kit User Guide <https://developer.nvidia.com/embedded/dlc/jetson-nano-developer-kit-user-guide>`_
- `Raspberry Valley: NVIDIA Jetson Nano <https://raspberry-valley.azurewebsites.net/NVIDIA-Jetson-Nano/>`_
