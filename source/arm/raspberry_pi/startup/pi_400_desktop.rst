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


