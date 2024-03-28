.. _pi_quick_start:

===============================
树莓派(Raspberry Pi)快速起步
===============================

本文概述树莓派操作系统安装方法，基于Debian版本，为大家展示如何快速安装操作系统并开始学习Linux系统。

下载
========

从 `树莓派官网 <https://www.raspberrypi.org/>`_ 可以下载镜像文件，通常推荐基于Debian的发行版 :strike:`Raspbian` :ref:`raspberry_pi_os` (新版命名) 。然后将镜像文件通过 ``dd`` 命令写入到U盘中:

.. literalinclude:: pi_quick_start/mkimg
   :caption: 将树莓派镜像写入U盘

.. note::

   这里写入磁盘的工具 ``dd`` 是Linux平台常用工具，上述写入设备是 ``/dev/sdb`` ，是U盘插入Linux电脑识别的磁盘设备。如果你使用其他操作系统，或者Linux电脑中安装的磁盘数量不同，则设备明会不相同。请按照实际设备设备处理。

( **这段已过时废弃** )现在 :ref:`pi_4` 官方推荐使用 `NOOBS (New Out Of Box Software) <https://www.raspberrypi.org/documentation/installation/noobs.md>`_ ，不过，由于早期的树莓派都是32为处理器，并且内存都不超过4GB，所以默认官方提供都树莓派操作系统都是32位的。2020年树莓派4B增加了8G规格，也就需要操作系统改用64位以支持超过4G内存。但当前(2020年9月)树莓派官方尚未提供64位正式版，所以推荐采用 `Ubuntu Server for Raspberry Pi <https://ubuntu.com/download/raspberry-pi>`_ 的64位系统。

当前(2024年)树莓派官方已经推出来基于Debian 12的64位稳定版操作系统，所以现在通常不需要第三方64位系统，直接采用官方Raspberry Pi OS的64位版本就能够充分发挥硬件性能。

创建树莓派镜像
===============

.. note::

   制作树莓派的启动TF卡，我是在macOS上完成，所以参考 `Create an Ubuntu image for a Raspberry Pi on MacOS <https://ubuntu.com/tutorials/create-an-ubuntu-image-for-a-raspberry-pi-on-macos#2-on-your-macos-machine>`_ 完成。

- 检查macOS磁盘::

   diskutil list

- 制作树莓派镜像::

   dd if=XXXX.img of=/dev/rdisk2 bs=100m

.. note::

   树莓派启动以后，如果采用的是官方镜像，会有一个引导过程方便你设置，这里不再详述。

   不过，2020年9月，我购买的新版64位树莓派4b，为了能够学习和实践64位ARM系统，我选择 :ref:`ubuntu64bit_pi` 。

.. note::

   2024年3月，我重新开始部署基于树莓派的 :ref:`kubernetes` 集群，已经转为采用官方Raspberry Pi OS 64位系统

配置树莓派初始环境
===================

使用chroot方式切换到树莓派系统
--------------------------------------

.. note::

   为了能够通过网线直接连接笔记本电脑，所以简化设置树莓派采用静态IP地址。我采用笔记本电脑直接连接一条短网线和树莓派通讯，中间不经过交换机。树莓派的电源由笔记本电脑的USB口供电。

  :ref:`run_kali_on_pi_zero` 采用了 `Offensive Security官方网站提供Kali Linux ARM Images <https://www.offensive-security.com/kali-linux-arm-images/>`_ 安装方法类似可以借鉴。

- 将前面通过 ``dd`` 命令复制好镜像的TF卡通过USB转接器连接到笔记本的USB接口，识别成 ``/dev/sdb`` 。

- 挂载 ``/dev/sdb2``（Linux分区）到 ``/mnt`` 分区，然后就可以修改配置::

   mount /dev/sdb2 /mnt

.. note::

   为了能够让树莓派第一次启动就进入预设环境（设置静态IP地址，启动ssh服务，设置密码），在前面完成树莓派TF卡文件系统挂载到笔记本（Linux操作系统）之后，采用chroot切换到树莓派环境。这样就可以模拟运行了树莓派操作系统，并且所有修改都会在树莓派环境生效。
   
   如果你没有使用 ``chroot`` 切换到树莓派操作系统环境。则下文中所有编辑配置文件都是在 ``/mnt`` 目录下的子目录，例如 ``/mnt/etc/dhcpcd.conf`` 配置文件就是树莓派的配置文件 ``/etc/dhcpcd.conf`` ； ``/mnt/etc/network/interfaces`` 对应树莓派配置文件 ``/mnt/etc/network/interfaces`` 。

- 采用chroot方式切换到树莓派操作系统::

   mount -t proc proc /mnt/proc
   mount --rbind /sys /mnt/sys
   mount --make-rslave /mnt/sys
   mount --rbind /dev /mnt/dev
   mount --make-rslave /mnt/dev
   
   chroot /mnt /bin/bash
   source /etc/profile
   export PS1="(chroot) $PS1"

设置有线网卡静态IP
------------------

- (之前实践的早期版本)配置 ``/etc/network/interfaces`` (按照 :ref:`debian` 标准配置网络方法)

.. literalinclude:: pi_quick_start/interfaces
   :caption: 按照 :ref:`debian` 标准配置网络

.. note::

   网卡接口可能随系统识别硬件而不同命名，例如在 :ref:`run_kali_on_pi_zero` 系统识别的有线网卡可能命名为 ``usb0`` 。

- 现在(2024年)最新的Raspberry Pi OS基于 :ref:`debian` 12 构建，默认采用 :ref:`networkmanager` 管理网络，所以配置较为复杂。Raspberry Pi OS提供了一个终端交互设置程序 :ref:`nmtui` ，可以交互完成设置。实际配置文件存储在 :ref:`networkmanager` 管理配置中

.. literalinclude:: ../../linux/ubuntu_linux/network/networkmanager/eth0.config
   :caption: 通过 ``nmtui`` 交互生成的树莓派静态IP地址配置文件 ``/etc/NetworkManager/system-connections/'Wired connection 1.nmconnection'``
   :emphasize-lines: 10-14

设置ssh默认启动
----------------

- 激活ssh服务默认启动，并启动ssh服务::

   sudo systemctl enable ssh
   sudo systemctl start ssh

设置pi用户帐号密码和root密码
-------------------------------------

.. note::

   之前旧版本Raspbian系统，默认用户帐号是 ``pi`` ，密码是 ``raspberry`` ，一定要第一时间修改成复杂密码，避免安全漏洞。此外，还要设置root用户密码。

   不过，目前最新的Raspberry Pi OS已经去除了默认的 ``pi`` 帐号，而是改成首次启动时通过交互界面让用户输入一个自定义的帐号以及设置密码。而且这个帐号是无需密码就能够 ``sudo`` 成root用户，这个管理员帐号非常重要，通常就是以这个自定义帐号登录系统。

- ( **新版本已经不再需要此步骤** )切换到超级用户 ``root`` 帐号下，然后分别为 ``pi`` 用户设置密码，以及为自己（ ``root`` ）设置密码::

   sudo su -
   passwd pi
   passwd

启动
------

现在可以启动树莓派。很简单，将USB线连接到笔记本电脑上提供电源，另外将网线连接树莓派网口和笔记本网口，笔记本网卡配置 ``192.168.7.1/24`` 就可以激活直联网络的网卡。

- 在笔记本上输入如下命令通过ssh登录树莓派::

   ssh pi@192.168.7.11

物理主机IP masquerade
=======================

.. note::

   本步骤非必须，只是我临时采用的方便树莓派通过我的笔记本连接互联网。实际实际上更为方便的方法是使用Android手机提供的 :ref:`vpn_hotspot`

上述通过网线直接连接树莓派和笔记本电脑虽然非常方便（无需交换机），也便于移动办公。但是此时树莓派尚未连接因特网，对于在线安装和更新软件非常不便。

简单的解决方法是使用 iptables 的 ``NAT masquerade`` ，即在笔记本（相当于树莓派的网关）输入如下命令（或执行脚本）::

   sudo iptables -t nat -A POSTROUTING -s 192.168.7.0/24 -o wlp3s0 -j MASQUERADE
   echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

.. note::

   对于现代的Fedora系统，已经使用 ``firewalld`` 来管理防火墙，可以不使用iptables米ing领。

设置firewalld
================

.. note::

   本步骤非必须，我发现最新 :ref:`raspberry_pi_os` 默认没有启用防火墙，所以这段是以前的实践记录，可以跳过。

- 首先检查有哪些激活的zone::

   sudo firewall-cmd --get-active-zones

显示输出::

   public
     interfaces: enp0s20u1 wlp3s0

可以看到有线网卡和无线网卡都默认设置为 public，所以默认拒绝外部访问。

- 检查有那些可用的zone::

   firewall-cmd --get-zones

显示输出::

   FedoraServer FedoraWorkstation block dmz drop external home internal public trusted work

- 现在检查 ``dmz`` 区域尚无接口::

   sudo firewall-cmd --zone=dmz --list-all

显示输出::

   dmz
     target: default
     icmp-block-inversion: no
     interfaces: 
     sources: 
     services: ssh
     ports: 
     protocols: 
     masquerade: no
     forward-ports: 
     source-ports: 
     icmp-blocks: 
     rich rules:

- 将和树莓派直接连接的有线网卡接口 ``enp0s20u1`` 迁移到 DMZ 区::

   sudo firewall-cmd --zone=dmz --change-interface=enp0s20u1

显示输出::

   The interface is under control of NetworkManager, setting zone to 'dmz'.
   success

- 再次检查激活区域::

   firewall-cmd --get-active-zones

显示输出::

   dmz
     interfaces: enp0s20u1
   public
     interfaces: wlp3s0

- 添加 ``dmz`` 区域允许访问的服务::

   firewall-cmd --permanent --zone=dmz --add-service={http,https,ldap,ldaps,kerberos,dns,kpasswd,ntp,ftp}
   firewall-cmd --reload

这样就使得树莓派能访问外部服务端口（实际上是在笔记本网卡接口上开启了这些服务的端口允许访问）

- 启用端口转发::

   echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/ip_forward.conf
   sudo sysctl -w net.ipv4.ip_forward=1

- 通过 ``firewall-cmd`` 启用MASQUERADE::

   firewall-cmd --permanent --zone=public --add-masquerade
   firewall-cmd --reload

树莓派进一步配置
=================

软件包安装
------------

如果采用最小的raspberry pi安装镜像，安装以后还需要一些工具包::

   sudo apt install screen wget curl bzip2 xz-utils sysstat \
   unzip nfs-common ssh mlocate dnsutils git gcc g++ make \
   sudo curl flex autoconf automake python

时区
------------

默认时区是UTC，和中国差距8小时，所以需要修改时区::

   sudo unlink /etc/localtime
   sudo ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

参考
=========

- `How to give your Raspberry Pi a Static IP Address - UPDATE <https://www.modmypi.com/blog/how-to-give-your-raspberry-pi-a-static-ip-address-update>`_
- `Raspberry Valley <https://raspberry-valley.azurewebsites.net/>`_ 提供了很多有价值的资料
