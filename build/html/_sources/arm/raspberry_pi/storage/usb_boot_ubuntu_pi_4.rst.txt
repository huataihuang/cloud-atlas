.. _usb_boot_ubuntu_pi_4:

=======================================
树莓派4 USB启动Ubuntu Server 20.04
=======================================

.. note::

   为了实现USB移动硬盘启动树莓派，我做了多次 :ref:`usb_boot_ubuntu_pi_4` ，所以虽然有了非常详细的排查过程，但是步骤上有些重复和散乱。所以，我重新整理一份操作手册，从我的实践经验来探索USB启动的最佳实践。

Raspbian和firmware
=====================

树莓派的USB启动需要更新和设置树莓派firmware，不过，我安装和使用的是 :ref:`ubuntu_linux` for Raspberry Pi，所以在Ubuntu 20.0.4  LTS操作系统中并没有包含树莓派firmware更新工具。解决的方法是，在SD卡中安装树莓派官方提供的Raspbian操作系统，利用raspbian中的firmware更新工具进行更新。

- 采用 :ref:`pi_quick_start` 中方法，我们先下载镜像并通过dd命令写入TF卡::

   sudo dd if=2020-08-20-raspios-buster-armhf-lite.img of=/dev/sdb bs=100M

- 然后将这个就绪的TF卡通过USB读卡连接到Linux主机上，执行以下命令，通过chroot切换到raspberry系统::

   mount /dev/sdb2 /mnt
   mount /dev/sdb1 /mnt/boot
   for f in dev dev/pts proc sys; do mount --bind /$f /mnt/$f;done
   export PS1="(chroot) $PS1"
   chroot /mnt/

- 更新最新的Raspbian系统::

   apt update
   apt upgrade

- 将Raspbian系统配置一个静态IP地址，这样就可以不需要外接显示器，直接通过ssh就可以登录树莓派操作，注意IP地址不要冲突，请参考 :ref:`studio_ip` 设置 ``192.168.6.110 raspberrypi`` 

在raspbian中，默认启动dhcpcd会自动配置IP地址，可以指定网卡接口使用静态IP地址，即修改 ``/etc/dhcpcd.conf`` 配置添加::

   interface eth0
   static ip_address=192.168.6.110/24
   static routers=192.168.6.9
   static domain_name_servers=202.96.209.133

注意，必须确保 ``dhcpcd.service`` 服务默认启动，上述配置才能生效::

   systemctl enable dhcpcd.service

- 然后卸载挂载的raspbian的TF卡，插入到树莓派中启动，然后测试是否能够按照上述静态IP地址访问ssh服务。

参考
=====

- `USB Boot Ubuntu Server 20.04 on Raspberry Pi 4 <https://eugenegrechko.com/blog/USB-Boot-Ubuntu-Server-20.04-on-Raspberry-Pi-4>`_
