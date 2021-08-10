.. _jetson_nano_startup:

======================
Jetson Nano快速起步
======================

NVIDIA :ref:`jetson_nano` Developer Kit是一个小型AI计算机，面向创客、学习者和开发者。使用这个mini设备，可以构建AI应用，超酷的AI机器人，甚至更多的 `Jetson 社区项目 <https://developer.nvidia.com/embedded/community/jetson-projects>`_ 。

.. note::

   2021年初，我重新 :ref:`deploy_jetson_server` 来作为 :ref:`kubernetes_arm` 集群工作节点。有一些部署改进和调整，请参考。

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

NVIDIA Jetson Nano Developer Kit操作系统提示问题：

- ``APP Patition Size`` 配置，这是因为安装镜像初始时候只占据大约13G， ``dd`` 到SD卡之后，初始化时提示可以扩展到整个SD卡存储空间。不过，我为了能够后续通过磁盘卷管理更好分配磁盘空间，所以只设置扩展到 ``24G`` 空间 (28896MB)

- ``Select Nvpmodel Mode`` - 该选项是电源管理，有两种模式 ``MAXN - (Default)`` (默认最大性能主频，使用4个CPU核心) / ``5W`` （节能模式，只使用2个CPU核心并且降低主频），选择默认就可以。这个配置在以后可以通过  ``nvpmodel`` 命令行或者GUI程序进行修改

早期发行版本要求在线连接Internet进行初始化，所以要确保Jetson Nano的主机已经连接到能够访问Internet的局域网，并且通过DHCP获得主机IP地址。这个过程是自动化的，并且如果不能获得互联网连接，就会导致启动任务死循环无法结束。不过，2021年7月我下载的最新镜像已经可以离线初始化，也就是可以在完成初始设置之后，再设置网络联网进行更新。

登陆界面是Gnome 3，所以图形界面比较沉重，甚至我觉得在ARM处理器的4G内存规格下，运行这么复杂的图形桌面实在是浪费了系统资源。

登陆初始化提供了选择键盘、时区以及初始账号功能，并且提供了通过网络连接Internet进行更新的选项。如果设备安装了无线网卡，则会提示设置连接WiFi。建议连接网络进行更新。

我的初始设置比较简单，就是将有线网卡设置为固定IP地址 ``192.168.6.10`` ，这样我就可以通过笔记本的有线网络连接到Jetson系统中，并进行远程操作。这样可以不需要连接显示器。

桌面修改
=========

桌面改为轻量级桌面， :ref:`jetson_xfce4` :

- 这个步骤首先完成，可以节约大量磁盘空间和内存占用，同时也避免了大量桌面软件更新
- 默认启动到字符界面，可以按需使用 ``startx`` 命令启动桌面；也可以使用 :ref:`xpra` 远程运行图形程序，可以最大程度节约系统资源

瘦身
======

NVIDIA Jetson nano的官方发行版默认安装了实际上对于我平时使用并没有用处的Office软件，所以我准备清理掉不需要的软件包::

   sudo apt remove --purge libreoffice* -y
   sudo apt remove --purge thunderbird* -y
   sudo apt clean -y
   sudo apt autoremove -y
   sudo apt update

安装必要工具软件::

   sudo apt install curl screen nmon lsof dnsmasq
   # 可选安装Xfce4桌面 - 我最终将jetson作为Kubernetes节点运行，所以没有安装任何桌面，配置成字符界面运行
   sudo apt install xfce4 xfce4-terminal
   # 以下可选
   sudo apt install fcitx-bin fcitx-googlepinyin
   sudo apt install bluez-tools blueman
   sudo apt install synergy keepassx

你可以选择轻量级 :ref:`xfce` ，也可以 :ref:`deploy_jetson_server` ，将主机加入到 :ref:`kubernetes` 作为worker节点。

.. note::

   实际上我是将Jetson作为 :ref:`kubernetes` 的工作节点来运行的，所以不需要图形桌面系统。我在2021年初再次重装时，选择移除Gnome桌面，但是也不安装任何桌面系统。系统保留了一些基础的X window程序，供后续通过 :ref:`remote_linux_desktop` 和 :ref:`xpra` 来实现远程桌面访问。或者，我可以部署一个 :ref:`jupyter` 的Hub模式，通过浏览器来使用图形系统。

电源管理
========

为能够获得较好的桌面性能，按照 :ref:`defs` 设置CPU按照performance模式运行::

   sudo apt-get install cpufrequtils
   echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils
   sudo systemctl disable ondemand

网络
==========

使用Netplan配置网络(未成功)
----------------------------

:ref:`netplan` 是Ubuntu 20.04开始主要的网络配置工具，比较简单易用。使用netplan作为前端配置工具，后端可以使用NetworkManager，也可以使用 ``syatemd-networkd`` 进行网络配置。对于比较简单的网络配置，特别是在 :ref:`arm` 运行环境，我希望尽量少占用系统资源，所以倾向于使用 ``systemd-networkd`` 避免再多安装一个 ``NetwrokManager`` 服务。

按照 :ref:`netplan` 配置网络，但是目前遇到无法调用systemd-networkd生成正确配置，暂时放弃。

使用Network Manager配置无线(旧版)
----------------------------------

.. note::

   当前我已经改为采用 :ref:`netplan` 来配置管理网络，主要原因是最新的Ubuntu 20.04默认采用netplan配置，我在 :ref:`ubuntu64bit_pi` 就采用了netplan，所以在Jetson上尝试netplan没有成功，所以目前还使用 :ref:`networkmanager` 配置网络。

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

- 增加公司无线配置 ``OFFICE`` 的AP上（配置设置成名为 ``MYOFFICE`` ）::

   nmcli con add con-name MYOFFICE ifname wlp3s0 type wifi ssid OFFICE \
   wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 \
   802-1x.identity "USERNAME" 802-1x.password "MYPASSWORD"

.. note::

   详细配置可参考 :ref:`set_ubuntu_wifi`

使用Network Manager配置无线(新版)
----------------------------------

2021年下半年，由于TF存储卡损坏，不得不重新安装了一次操作系统。此时我发现，网络配置管理默认已经改成了 :ref:`systemd_networkd` ，所以需要配置 :ref:`systemd_networkd` 和 :ref:`systemd_networkd_wlan`

- 有线网卡配置 ``/etc/systemd/network/10-eth0.network`` 参考 :ref:`systemd_networkd` :

.. literalinclude:: jetson_nano_startup/10-eth0.network
   :language: bash
   :linenos:
   :caption:

- 无线网卡配置 ``/etc/systemd/network/20-wlan0.network`` 参考 :ref:`systemd_networkd_wlan` :

.. literalinclude:: jetson_nano_startup/20-wlan0.network
   :language: bash
   :linenos:
   :caption:

- 配置5GHz无线网络的国家代码 ``/etc/default/crda`` ::

   REGDOMAIN=CN

- 创建 ``/etc/wpa_supplicant/wpa_supplicant-wlan0.conf`` :

.. literalinclude:: jetson_nano_startup/wpa_supplicant-wlan0.conf
   :language: bash
   :linenos:
   :caption:

- 由于在 ``20-wlan0.network`` 中配置了MAC spoof，所以需要重启一次 ``systemd-networkd`` ::

   systemctl daemon-reload
   systemctl restart systemd-networkd

完成后检查一下 ``wlan0`` 接口是否正确修正了MAC地址

- 启用 ``systemd-networkd`` 的 ``wpa_supplicant`` 服务::

   systemctl enable wpa_supplicant@wlan0
   systemctl start wpa_supplicant@wlan0

- 然后检查 ``systemd`` 服务::

   systemctl status wpa_supplicant@wlan0

然后检查 ``ip addr``

蓝牙(可选)
===========

- 安装蓝牙管理工具::

   apt install bluetools blueman

- 然后启动蓝牙服务::

   systemctl start bluetooth

在 :ref:`jetson_xfce4` 中可以使用blueman图形管理工具直接管理蓝牙设备。

.. note::

   如果使用蓝牙键盘，可以采用上述简单的方式在图形系统中支持使用蓝牙键盘。

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

远程访问
===========

Xpra远程X应用(推荐)
----------------------

为了能够随时进入开发状态，我现在采用 :ref:`xpra` 来实现远程X window程序运行，非常轻量级的融合VNC和X window的远程图形运行方案。

我在 :ref:`jetson_xpra` 中详细记录在ARM架构下实践。

远程桌面(可选)
----------------

.. note::

   如果你需要完整的桌面系统，可以选择采用xrdp方式的远程桌面，如本小节概述。这是我最初远程访问Jetson的方法，并且也是比较通用桌面访问方法(客户端跨平台，特别是对Windows用户非常友好)。

   不过，我现在比较喜欢采用 :ref:`xpra` 方式，可以单个或多个应用程序无缝融合到本地桌面操作系统，类似于 :ref:`seamless_rdp` 实现。

虽然Jetson nano可以通过直接连接键盘鼠标和显示器进行操作，但是我更希望将这个设备作为远程访问的的边缘AI设备。所以， :ref:`jetson_remote` 可以方便我们以图形界面方式使用。

.. note::

   如果你把Jetson Nano作为桌面系统使用，基本上轻量级的使用没有任何问题。主要的限制是磁盘IO，如果没有快速的TF卡支持，或者通过外接SSD磁盘运行系统，日常使用中IO Wait会导致系统卡顿。但是，只要你能够使用快速的存储系统，则Jetson作为个人桌面系统完全没有压力。

参考
======

- `Getting Started With Jetson Nano Developer Kit <https://developer.nvidia.com/embedded/learn/get-started-jetson-nano-devkit>`_
- `Jetson Nano Developer Kit User Guide <https://developer.nvidia.com/embedded/dlc/jetson-nano-developer-kit-user-guide>`_
- `Raspberry Valley: NVIDIA Jetson Nano <https://raspberry-valley.azurewebsites.net/NVIDIA-Jetson-Nano/>`_
- `How to configure networking with Netplan on Ubuntu <https://vitux.com/how-to-configure-networking-with-netplan-on-ubuntu/>`_
- `Have a Plan for Netplan <https://www.linuxjournal.com/content/have-plan-netplan>`_
