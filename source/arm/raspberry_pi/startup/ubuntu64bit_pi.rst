.. _ubuntu64bit_pi:

=======================
树莓派4b运行64位Ubuntu
=======================

为了能够充分发挥最新的64位树莓派性能，我采用64位Ubuntu Server进行部署安装，目标是在树莓派上实践64位ARM架构的Linux操作系统，包括但不限于：

- 部署 :ref:`kubernetes`
- 编译和优化64位ARM :ref:`kernel`
- 规模化自动部署ARM集群
- 探索ARM环境编程

下载镜像
===========

从Ubuntu官方下载 `Ubuntu 20.04.1 LTS for Raspberry Pi 2,3 or 4 <https://ubuntu.com/download/raspberry-pi>`_ ，下载的文件是 `.xz` 压缩文件，解压缩以后，通过 ``dd`` 命令写入到TF卡::

   dd if=ubuntu-20.04.1-preinstalled-server-arm64+raspi.img of=/dev/rdisk2 bs=100m

启动
=======

我选择安装的是Ubuntu Server for Raspberry Pi，这个版本安装没有任何交互，直接启动以后，通过终端使用账号 ``ubuntu`` 登陆即可使用(密码和账号名相同，首次登陆会强制修改)。

.. note::

   Ubuntu镜像刷到TF卡或者USB外接存储磁盘以后，首次启动会把 ``/dev/sda2`` 挂载的根目录自动扩展到整个磁盘空间。对于我部署 :ref:`ceph` 和 :ref:`gluster` 并构建 :ref:`kubernetes` 来说，存储分区不合理。所以，我采用 :ref:`resize_ext4_rootfs` 调整文件系统分区。

网络
=====

在我的 :ref:`pi_cluster` 中，我将有线网络通过千兆桌面交换机连接，构建一个内部高速网络，以便实现分布式环境，部署 :ref:`kubernetes` 以及 :ref:`ceph` / :ref:`gluster` 。

静态IP地址配置
-----------------

- 初次启动，如果没有DHCP提供网络IP地址，可以手工设置::

   ip addr add 192.168.6.15/25 dev eth0
   ip route add default via 192.168.6.9

- 完成基本的操作系统升级之后，有线网口的静态IP地址采用 :ref:`netplan` 配置，设置方法见 :ref:`pi_4_network`

无线网络
----------

`How to install Ubuntu on your Raspberry Pi - 3. Wi-Fi or Ethernet <https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#3-wifi-or-ethernet>`_ 提供了一个在安装过程中设置WiFi的步骤，即编辑SD卡的 ``system-boot`` 分区中的 ``network-config`` 文件，去除掉以下段落的注释符号 ``#`` 类似如下::

   wifis:
     wlan0:
     dhcp4: true
     optional: true
     access-points:
       <wifi network name>:
       password: "<wifi password>"

然后保存。然后用这个SD卡首次启动树莓派，就会自动连接WiFi。

Ubuntu for Raspberry Pi默认已经识别了树莓派的无线网卡，之前在 :ref:`ubuntu_on_mbp` 和 :ref:`ubuntu_on_thinkpad_x220` 都使用了NetworkManager :ref:`set_ubuntu_wifi` 。但是这种方式实际上多安装了组件，并且和默认netplan使用的 ``systemd-networkd`` 是完成相同工作，浪费系统内存资源。

所以，建议采用系统已经安装的 ``netplan`` + ``networkd`` 后端来完成无线设置。请参考 :ref:`pi_4_network` 完成设置。

时区
-------

- 默认是UTC时区，需要修改成本地时区，例如Shanghai::

   sudo unlink /etc/localtime
   sudo ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

停用unattended-upgrades(可选)
------------------------------

当前为了能够控制升级，特别是 :ref:`usb_boot_ubuntu_pi_4` 需要手工处理内核解压缩，同时为了能够降低系统内存消耗。我关闭了 :ref:`unattended_upgrade` ::

   systemctl disable unattended-upgrades
   systemctl stop unattended-upgrades

桌面系统(不建议)
==================

默认安装的Ubuntu Server是纯字符界面系统，保持了精简的系统部署，提供了极大的灵活性。所以，如果你需要将服务器版本改造成桌面系统也是可能的(虽然我不建议在服务器上安装桌面软件)。

- 首先更新系统软件包::

   sudo apt update
   sudo apt upgrade

- 通过以下 ``apt install`` 命令选择一个桌面进行安装::

   # 轻量级桌面Xfce4
   sudo apt install xubuntu-desktop
   # 轻量级桌面LXDE
   sudo apt install lubuntu-desktop
   # 全功能桌面Gnome
   sudo apt install ubuntu-desktop
   # 全功能桌面KDE
   sudo apt-get install kubuntu-desktop

.. note::

   对于 :ref:`jetson` 或者 :ref:`pi_4` 这样硬件有一定限制的ARM系统，推荐采用轻量级桌面系统，例如 :ref:`xfce` 。如果系统默认采用了资源消耗严重的Gnome，例如Jetson Nano默认桌面是Gnome，你也可以将 :ref:`jetson_xfce4` 。
