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

   在国内访问NVIDIA的软件仓库非常缓慢，甚至无法连接。目前我采用的临时方法是翻墙，虽然速度缓慢，但是至少能够连接更新。有待寻找到更好的方法。

- 升级系统::

   sudo apt update
   sudo apt upgrade

- 清理掉不需要的软件包::

   sudo apt autoremove

瘦身
======

NVIDIA Jetson nano的官方发行版默认安装了很多桌面软件，实际上对于我平时使用并没有用处。例如Office软件，所以我准备清理掉不需要的软件包::

   sudo apt remove 

参考
======

- `Getting Started With Jetson Nano Developer Kit <https://developer.nvidia.com/embedded/learn/get-started-jetson-nano-devkit>`_
- `Jetson Nano Developer Kit User Guide <https://developer.nvidia.com/embedded/dlc/jetson-nano-developer-kit-user-guide>`_
