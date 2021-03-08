.. _pi_400_desktop:

=========================
Raspberry Pi 400桌面定制
=========================

终于入手了 :ref:`pi_400` ，我最初的想法是 :ref:`fydeos_pi` ，但是似乎目前的FydeOS的显示输出对我的显示器支持存在问题。加上我主要的目标是想研究 :ref:`chromium_os` 的结构，所以我准备改成直接在 :ref:`pi_4` 上编译和构建chromium os。但是，Raspberry Pi 400则想先运行轻量级的精简Linux桌面系统，同时编译 :ref:`anbox` 来运行Android程序(ARM架构)。

.. note::

   当前Raspberry Pi OS没有提供官方64位操作系统，所以 :ref:`pi_400` 运行的是32位操作系统。为了能够充分发挥 :ref:`pi_4` 的64位架构能力( :ref:`pi_cluster` 使用的是 :ref:`pi_4` 的8G内存硬件 )，同时构建 :ref:`kubernetes_arm` 集群，在服务器端我使用的是64位Ubuntu ARM版本。

目标
======

- 使用官方原生Raspberry Pi OS，但是从 ``Raspberry Pi OS Lite`` (字符终端版本) 开始定制，只安装最精简的必要软件
- 在主机上构建 :ref:`anbox` 来运行基础的Android应用程序，以便通过 :ref:`android` 来弥补Linux的一些商业应用程序不足

  - 由于虚拟化非常消耗资源，实际我把所有ARM虚拟机都运行在 :ref:`pi_cluster` ，远程运行Android程序

- 本地开发环境通过Docker来构建
  
  - 为了能够降低客户端资源消耗，我使用多台树莓派和Jetson Nano构建 :ref:`kubernetes_arm` ，所以容器都运行在服务器端，桌面电脑几乎不需要消耗资源

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

键盘布局
==========

在国内购买的树莓派默认使用US键盘布局，但是树莓派是英国开发的，默认操作系统键盘布局是UK。请参考 `How to Change your Keyboard Layout on Raspberry Pi? (Raspbian) <How to Change your Keyboard Layout on Raspberry Pi? (Raspbian)>`_ 调整键盘布局。

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

应用软件
==========

- 终端

默认安装的终端是 ``uxterm`` ，但是对中文字体显示不友好。所以还是安装Xfce4的默认终端::

   apt install xfce4-terminal

- 浏览器

默认安装的Xfce4桌面已经具备了一些基础软件，不过还需要浏览器。我比较倾向于使用开源的firefox，但是实际工作中很多业务网站已经完全chrome化了(就像当年微软的IE强制使用特殊的功能)，导致不得不同时安装两个浏览器::

   apt install firefox-esr chromium

``firefox-esr`` 是 ``Extended Support Release (ESR)`` 

如果需要切换默认浏览器，则执行::

   sudo update-alternatives --config x-www-browser

- 安装中文字体(文泉驿微米黑)和输入法fcitx::

   apt install fonts-wqy-microhei fcitx fcitx-googlepinyin

安装fcitx会安装很多依赖软件包，主要是针对qt和gtk的库，非常庞大。如果不需要中文输入，仅仅作为中文浏览可以不安装。

- 修订 ``.xinitrc`` ::

   export GTK_IM_MODULE=fcitx
   export QT_IM_MODULE=fcitx
   export XMODIFIERS=@im=fcitx
   exec fcitx &
   exec startxfce4

- 重新登陆Xfce4桌面，然后执行 ``fcitx-configtool`` 命令进行配置。

- 安装 :ref:`synergy`

- 安装 :ref:`vs_code`
