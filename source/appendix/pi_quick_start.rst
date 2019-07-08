.. _pi_quick_start:

===============================
树莓派(Raspberry Pi)快速起步
===============================

本文概述树莓派操作系统安装方法，基于Debian版本，为大家展示如何快速安装操作系统并开始学习Linux系统。

下载
========

从 `树莓派官网 <https://www.raspberrypi.org/>`_ 可以下载镜像文件，通常推荐基于Debian的发行版 Raspbian 。然后将镜像文件通过 ``dd`` 命令写入到U盘中::

   sudo dd if=2017-11-29-raspbian-stretch-lite.img of=/dev/sdb bs=4M

.. note::

   这里写入磁盘的工具 ``dd`` 是Linux平台常用工具，上述写入设备是 ``/dev/sdb`` ，是U盘插入Linux电脑识别的磁盘设备。如果你使用其他操作系统，或者Linux电脑中安装的磁盘数量不同，则设备明会不相同。请按照实际设备设备处理。

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

- 配置 ``/etc/network/interfaces`` ::

   iface eth0 inet static
        address 192.168.7.10
        netmask 255.255.255.0
        network 192.168.7.0
        broadcast 192.168.7.255
        gateway 192.168.7.1
        dns-nameservers 192.168.7.1

.. note::

   网卡接口可能随系统识别硬件而不同命名，例如在 :ref:`run_kali_on_pi_zero` 系统识别的有线网卡可能命名为 ``usb0`` 。

设置ssh默认启动
----------------

- 激活ssh服务默认启动::

   sudo systemctl enable ssh

- 启动ssh服务::

   sudo systemctl start ssh

设置pi用户帐号密码和root密码
-------------------------------------

.. note::

   对于树莓派使用的Raspbian系统，默认用户帐号是 ``pi`` ，密码是 ``raspberry`` ，一定要第一时间修改成复杂密码，避免安全漏洞。此外，还要设置root用户密码。

- 切换到超级用户 ``root`` 帐号下，然后分别为 ``pi`` 用户设置密码，以及为自己（ ``root`` ）设置密码::

   sudo su -
   passwd pi
   passwd

启动
------

现在可以启动树莓派。很简单，将USB线连接到笔记本电脑上提供电源，另外将网线连接树莓派网口和笔记本网口，笔记本网卡配置 ``192.168.7.1/24`` 就可以激活直联网络的网卡。

- 在笔记本上输入如下命令通过ssh登录树莓派::

   ssh pi@192.168.7.10

物理主机IP masquerade
=======================

上述通过网线直接连接树莓派和笔记本电脑虽然非常方便（无需交换机），也便于移动办公。但是此时树莓派尚未连接因特网，对于在线安装和更新软件非常不便。

简单的解决方法是使用 iptables 的 ``NAT masquerade`` ，即在笔记本（相当于树莓派的网关）输入如下命令（或执行脚本）::

   sudo iptables -t nat -A POSTROUTING -s 192.168.7.0/24 -o wlp3s0 -j MASQUERADE
   echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

.. note::

   对于现代的Fedora系统，已经使用 ``firewalld`` 来管理防火墙，可以不使用iptables米ing领。

设置firewalld
---------------

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
