.. _wpa_supplicant:

====================================
使用wpa_supplicant连接无线网络
====================================

一直以来，我们都会使用发行版默认使用的网络配置工具来设置网络，例如Ubuntu默认使用 :ref:`netplan` ，而RedHat或者其他发行版默认使用 ``NetworkManager`` 。总之，工具五花八门，特别是设置企业级无线网络WPA2，命令参数更是复杂多变。

然而，实际上不同的网络配置工具在配置无线网络时，最终生成的配置文件和使用的工具其实都是 ``wpa_supplicant`` ，所以我们也可以手工编辑 ``wpa_supplicant`` 配置文件或者使用 ``wpa_supplicant`` 命令来构建初始配置并进行进一步定制。

激活无线网卡
===============

- 首先我们需要确保无线网卡是激活的，使用工具 ``rfkill`` ::

   sudo apt install rfkill

- 检查无线网卡状态::

   rfkill list

如果看到无线网卡状态是 ``Soft blocked`` 则表明软件关闭了无线网卡::

   0: phy0: Wireless LAN
           Soft blocked: yes
           Hard blocked: no

则使用以下命令启用无线(unblock)::

   rfkill unlock wifi

- 如果使用桌面版本Ubuntu，默认是启用了NetworkManager，则会和手工设置 ``wpa_supplicant`` 冲突，所以需要停止NetworkManager::

   sudo systemctl stop NetworkManager
   sudo systemctl disable NetworkManager

- 如果使用服务器版本Ubuntu，默认是启用了netplan，也会和手工设置 ``wpa_supplicant`` 冲突

确定无线网卡
=============

- 使用 ``iwconfig`` 找出无线网卡名字::

   iwconfig

通常无线网卡名字是 ``wlan0`` ，但是也可能看到常见的 ``wlp3s0`` 。

- 如果无线网卡接口是down状态，可以使用 ``ifconfig`` 命令启用::

   sudo ifconfig wlp3s0 up

- 然后扫描周边无线网络::

   sudo iwlist wlp3s0 scan | grep ESSID

使用wpa_supplicant连接无线
============================

- 安装 ``wpa_supplicant`` ::

   sudo apt install wpasupplicant

- 创建初始配置::

   wpa_passphrase your-ESSID your-passphrase | sudo tee /etc/wpa_supplicant.conf

- 使用以下命令连接无线::

   sudo wpa_supplicant -c /etc/wpa_supplicant.conf -i wlp3s0

注意，这时是前台运行 wpa_supplicant ，当连接建立以后，请另外开一个终端窗口，执行 ``iwconfig`` 命令检查无线是否连接正常，应该看到 ``wlps3s0`` 连接到指定的AP。

- 按下 ``CTRL+C`` 终止前台运行的 ``wpa_supplicant`` 进程，然后加上 ``-B`` 参数让它后台运行::

   sudo wpa_supplicant -B -c /etc/wpa_supplicant.conf -i wlp3s0

- 当完成无线连接之后，我们需要获取DHCP地址，所以我们还要运行 ``dhclient`` ::

   sudo dhclient wlp3s0

如果一切正常，使用 ``ifconfig wlp3s0`` 将看到无线网卡获得IP地址并能够正常上网。

连接隐藏的无线网络
==================

有些无线网络SSID并不广播，所以需要在 ``/etc/wpa_supplicant.conf`` 配置中添加::

   scan_ssid=1

启动时自动运行
================

为了能在操作系统启动时自动连接无线网络，我们需要编辑 ``wpa_supplicant.service`` 配置::

   sudo cp /lib/systemd/system/wpa_supplicant.service /etc/systemd/system/wpa_supplicant.service

然后编辑 ``/etc/systemd/system/wpa_supplicant.service`` ，将以下配置::

   ExecStart=/sbin/wpa_supplicant -u -s -O /run/wpa_supplicant

修改成::

   ExecStart=/sbin/wpa_supplicant -u -s -c /etc/wpa_supplicant.conf -i wlp3s0

如果在 ``wpa_supplicant.service`` 配置中有如下内容::

   Alias=dbus-fi.w1.wpa_supplicant1.service

则注释掉(添加 ``#`` )::

   #Alias=dbus-fi.w1.wpa_supplicant1.service

现在我们可以激活 ``wpa_supplicant.service`` ::

   sudo systemctl enable wpa_supplicant.service

我们也需要启动 dhclient 来获得IP，所以创建 ``/etc/systemd/system/dhclient.service`` 内容如下::

   [Unit]
   Description= DHCP Client
   Before=network.target

   [Service]
   Type=simple
   ExecStart=/sbin/dhclient wlp3s0 -v
   ExecStop=/sbin/dhclient wlp3s0 -r

   [Install] 
   WantedBy=multi-user.target

然后激活服务::

   sudo systemctl enable dhclient.service

获得静态IP地址
==============

DHCP客户端也可以向服务器请求分配固定的IP地址，编辑 ``/etc/dhcp/dhclient.conf`` 添加以下行内容::

   interface "wlp3s0" {
        send dhcp-requested-address 192.168.0.122;
   }

然后重启dhclient服务::

   sudo systemctl restart dhclient

使用主机名访问Ubuntu服务
===========================

实际上不需要分配静态IP地址就能够对外提供服务。Ubuntu可以使用 mDNS (Multicast DNS) 来向局域网公告自己的主机名，这样客户端就可以通过主机名来访问这台服务器上的服务。这样主机名可以解析到IP地址，即使你的主机IP地址变化。

要使用mDNS，需要安装 ``avahi-daemon`` ，这时一个实现 ``mDNS/DNS-SD`` 的开源实现::

   sudo apt install avahi-daemon

启动服务::

   sudo systemctl start avahi-daemon

激活启动服务::

   sudo systemctl enable avahi-daemon

avahi-daemon监听在UDP端口5353，所以防火墙需要打开这个端口。如果你使用UFW，则运行以下命令::

   sudo ufw allow 5353/udp

现在你需要设置服务器的唯一主机名，使用 ``hostnamectl`` 命令::

   sudo hostnamectl set-hostname ubuntubox

注意，此时新设置的 ``ubuntubox`` 还不能被其他局域网主机看到，我们需要重启 ``avahi-daemon`` ::

   sudo systemclt restart avahi-daemon

检查 avahi-daemon 状态::

   systemctl status avahi-daemon

.. note::

   需要注意，mDNS主机名以 ``.local`` 结尾，所以上述设置主机名 ``ubuntubox`` 在mDNS中显示的名字是 ``ubuntubox.local``

对于要使用avahi的客户端，需要安装  ``mDNS/DNS-SD`` 软件:

- Linux需要安装 ``avahi-daemon``
- Windows需要激活 ``Bonjour`` 服务，也就是安装 `Bonjour print service <https://support.apple.com/kb/DL999?locale=en_US>`_ 或者直接安装 `iTunes <https://www.microsoft.com/en-us/p/itunes/9pb2mz1zmb1s>`_
- macOS不需要安装任何软件，默认已经激活了Bonjour

参考
=======

- `Using WPA_Supplicant to Connect to WPA2 Wi-fi from Terminal on Ubuntu 16.04 Server <https://www.linuxbabe.com/command-line/ubuntu-server-16-04-wifi-wpa-supplicant>`_
