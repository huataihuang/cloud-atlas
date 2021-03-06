.. _pi_400_desktop:

=========================
Raspberry Pi 400桌面定制
=========================

终于入手了 :ref:`pi_400` ，我最初的想法是 :ref:`fydeos_pi` ，但是似乎目前的FydeOS的显示输出对我的显示器支持存在问题。加上我主要的目标是想研究 :ref:`chromium_os` 的结构，所以我准备改成直接在 :ref:`pi_4` 上编译和构建chromium os。但是，Raspberry Pi 400则想先运行轻量级的精简Linux桌面系统，同时编译 :ref:`anbox` 来运行Android程序(ARM架构)。

目标
======

- 使用官方原生Raspberry Pi OS，但是从 ``Raspberry Pi OS Lite`` (字符终端版本) 开始定制，只安装最精简的必要软件
- 在主机上构建 :ref:`anbox` 来运行基础的Android应用程序，以便通过 :ref:`android` 来弥补Linux的一些商业应用程序不足
- 本地开发环境通过Docker来构建

安装
=====

- ``SO EASY`` - 下载、校验、解压、制作启动TF卡::

   openssl sha256 2021-01-11-raspios-buster-armhf-lite.zip
   unzip 2021-01-11-raspios-buster-armhf-lite.zip
   sudo dd if=2021-01-11-raspios-buster-armhf-lite.img of=/dev/sdc bs=100M

- 通过制作的 ``Raspberry Pi OS Lite`` TF卡启动树莓派400，可以看到首次启动会扩容根文件系统，然后重启进入字符终端界面

网路设置
=========

既然我们初始安装的是最简化操作系统，我们所有的定制都需要通过网络，所以我们首先需要配置树莓派连接Internet。

修订主机名
------------

- 通过 ``hostnamectl`` 修订主机名::

   hostnamectl set-hostname pi400

静态IP配置
--------------

- 默认 ``/etc/systemd/network`` 目录下有一个软链接::

   99-default.link -> /dev/null

这个实际上没有启用 ``systemd-networkd`` 所以移除::

   unlink /etc/systemd/network/99-default.link

- 使用最精简的配置方法 :ref:`systemd_networkd` 配置静态IP，创建::

   systemctl stop dhcpcd
   systemctl disable dhcpcd

- 在 ``/etc/systemd/network`` 目录下创建 ``10-eth0.network``

.. literalinclude:: pi_400_desktop/10-eth0.network
   :language: bash
   :linenos:
   :caption:

- 启动并激活 ``systemd-networkd`` ::

   systemctl start systemd-networkd
   systemctl enable systemd-networkd

DNS解析器配置
-----------------

使用 :ref:`systemd_resolved` 可以实现DNS解析器管理以及本地DNS服务:

- 修改 ``/etc/systemd/resolved.conf`` :

.. literalinclude:: pi_400_desktop/resolved.conf
   :language: bash
   :linenos:
   :caption:

- 启动并激活 ``systemd-resolved`` ::

   systemctl start systemd-resolved
   systemctl enable systemd-resolved

启动ssh
===========

- 启动ssh服务并激活::

   systemctl start ssh
   systemctl enable ssh

安装使用screen
================

为了能够不间断更新，强烈建议使用screen运行运维操作::

   apt install screen

- 配置 ``~/.screenrc`` 如下:

.. literalinclude:: ../../../linux/ubuntu_linux/screenrc
   :language: bash
   :linenos:
   :caption:

- 然后执行 ``screen -S works`` 启用一个远程控制台，就可以继续执行系统升级更新等操作

操作系统更新
===============

- 操作系统更新::

   apt update
   apt upgrade

备份镜像
==========

安装和更新树莓派操作系统是一个比较繁琐的过程(墙内更新树莓派网速非常慢)，由于我考虑可能会不断推倒重装，所以考虑在更新完成后先做一次镜像备份。另外，如果需要维护大量的服务器，则可以采用自建Ubuntu软件仓库镜像或者 :ref:`centos_local_http_repo` 来实现大规模操作系统更新。

- 将TF卡再次插入读卡器，通过以下命令进行备份::

   dd if=/dev/sdc bs=100M status=progress | xz | dd of=raspios-lite.img.xz

不过，上述方法对于128G的U盘并不友好，实际上是完全浪费了大量的空间(实际备份数据只有1.3GB)。我想到一个比较好的方法是，直接通过修改官方下载的镜像：先将镜像挂载到本地，然后通过chroot方式进入，更新和修订配置。这样得到的镜像可以直接使用。

.. note::

   `How to dd a remote disk using SSH on local machine and save to a local disk <https://unix.stackexchange.com/questions/132797/how-to-dd-a-remote-disk-using-ssh-on-local-machine-and-save-to-a-local-disk>`_ 提供了一个远程dd备份的方法可以参考::

      ssh user@remote "dd if=/dev/sda | gzip -1 -" | dd of=image.gz

.. warning::

   实践发现这种 ``dd`` 方式备份效率实在太低，最终我放弃了这个方法。备份建议采用 :ref:`recover_system_by_tar`

修订时区localtime
===================

默认安装完成raspios系统， ``localtime`` 时区是 ``London`` 修改修订成本地时区，例如 ``Shanghai`` ::

   unlink /etc/localtime
   ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

然后通过 ``date`` 命令检查一下时间，看看是否正确显示本地时间。

基础桌面
===========

我最中意的桌面是轻巧兼功能的 :ref:`xfce` ，同样在 :ref:`jetson_xfce4` ，现在在Raspberry Pi 400上我也采用Xfce4 ::

   apt install xfce4

- 在用户目录添加 ``~/.xinitrc``  内容如下::

   exec startxfce4

- 这样就可以通过 ``startx`` 命令启动进入桌面

无线设置
=========

首次使用Raspberry Pi 400，终端会提示::

   Wi-Fi is currently blocked by rfkill.
   Use raspi-config to set the country before use.

:ref:`raspi_config` 是一个终端交互配置工具，非常方便设置一些系统功能。上述提示表明，在启用Wi-Fi之前，首先需要设置 ``WLAN Contry`` ，这是因为 5GHz WiFi需要明确设置 ``country=CN`` 才能激活使用。 ( :ref:`wpa_supplicant` 实践中可以看到必须设置 ``country=CN`` ，如果使用 :ref:`netplan` 配置，则需要配置 ``/etc/default/crda`` 设置项 ``REGDOMAIN=CN`` )

- 启动WiFi接口::

   rfkill list
   rfkill unblock wifi
   
- 通过 :ref:`systemd_networkd_wlan` 连接无线
