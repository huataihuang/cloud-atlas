.. _ubuntu_on_mbp:

===========================
MacBook Pro上运行Ubuntu
===========================

安装
=========

现代的Linux操作系统桌面实际上已经非常完善，对于硬件的支持也非常好，除了由于Licence限制无法直接加入私有软件需要特别处理，几乎可以平滑运行在常用的电脑设备上。当然，对于MacBook Pro支持也非常完善。

安装提示：

- MacBook Pro/Air使用了UEFI（取代了传统的BIOS），这要求硬盘上必须有一个FAT32分区，标记为EFI分区

.. note::

   在Ubuntu安装过程中，磁盘分区中需要先划分的primary分区，标记为EFI分区。这步骤必须执行，否则安装后MacBook Pro无法从没有EFI分区的磁盘启动。

   Ubuntu Desktop版本安装比较灵活，可以自定义EFI分区大小，例如，可以设置200MB。但是，如果使用Ubuntu Server版本，则会强制设置512MB（大小不可调整），而且是系统自动选择创建在 ``/dev/sda1`` 。

- Ubuntu操作系统 ``/`` 分区需要采用 ``Ext4`` 文件系统，实践发现和Fedora不同，采用 Btrfs 作为根文件系统（ 特别配置了 ``XFS`` 的 ``/boot`` 分区）无法启动Ubuntu。

.. warning::

   Ubuntu Server版本的安装是非常死板的，会抹掉整个磁盘，重新创建GPT磁盘分区表。所以，即使原先磁盘空闲空间，并且想保留数据磁盘的分区也是不可能的。

- 最小化安装

最小化安装对于运行云计算平台OpenStack，以及兼顾一些日常工作已经足够。没有必要完整安装大量的应用软件。

.. note::

   可以参考我汇总各阶段设置部署安装的软件包列表： :ref:`ubuntu_packages`

timezone
----------

安装完成Unbuntu Server会发现系统时钟不是本地时钟（东8区），这个解决方法是修改 ``/etc/localtime`` 这个软链接文件的指向::

   sudo unlink /etc/localtime
   sudo ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

完成后再使用 ``date`` 命令检查时间就是本地时间了。

硬件设备
===========

无线网卡
-------------

- Ubuntu Server（当前采用）

我在安装Ubuntu Server时，采用了一块USB网卡连接有线网络，这样可以完整把整个安装过程进行结束。安装完成之后，通过以下方式安装驱动 :ref:`ubuntu_packages_wifi` ::

   sudo apt-get update
   sudo apt-get --reinstall install bcmwl-kernel-source

- Ubuntu Desktop LiveCD

Ubuntu Desktop在安装过程中是可以识别MacBook Pro的无线网卡（Broadcom BCM 43xx），但是，安装完成后，由于Licence限制，默认是没有安装网卡驱动，导致无法识别网卡，也不能连接网络。

不过，Ubuntu Desktop的LiveCD是包含了网卡驱动的，所以通过将LiveCD镜像挂载并作为APT的软件仓库源，就可以直接安装 ``Broadcom STA无线驱动（私有）``::

   mkdir /media/cdrom
   mount -t iso9660 -o loop ~/ubuntu-budgie-18.10-desktop-amd64.iso /media/cdrom
   apt-cdrom -m -d /media/cdrom add

   sudo apt-get update
   sudo apt-get --reinstall install bcmwl-kernel-source

此外，这个驱动似乎在IPv6激活启动时出现call trace，所以增加 ``/etc/sysctl.d/10-ipv6-disalbe.conf`` 配置如下::

   net.ipv6.conf.all.disable_ipv6 = 1

然后运行 ``sysctl -p /etc/sysctl.d/10-ipv6-disalbe.conf`` 或重启主机

不过，还是发现重启主机后IPv6被激活，所以改为内核传递参数禁止IPv6，即编辑 ``/etc/default/grub`` 设置::

   GRUB_CMDLINE_LINUX="ipv6.disable=1"

然后执行 ``update-grub`` 并重启系统来关闭IPv6

.. note::

   详细请参考 `Ubuntu在MacBook Pro上WIFI <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/ubuntu/install/ubuntu_on_macbook_pro_with_wifi.md>`_

显卡(可选)
----------------

.. note::

   只有需要使用图形界面才需要安装Nvdia驱动，如果只是单纯使Ubuntu作为服务器，可忽略此步骤。

MacBook Pro使用的显卡是NVIDIA GeForce GT 750M Mac Edition ，默认安装的显卡驱动是开源的 nouveau ，这个驱动对于硬件加速比官方的闭源驱动要差，所以推荐采用官方驱动。

.. note::

   详细参考 `在Ubuntu 18.10安装Nvidia驱动 <https://github.com/huataihuang/cloud-atlas-draft/tree/master/os/linux/ubuntu/install/install_nvidia_drivers_on_ubuntu_18_10.md>`_

- 安装 ``ubuntu-drivers`` 工具包::

   sudo apt install ubuntu-drivers-common

- 列出建议驱动版本::

   ubuntu-drivers devices

- 安装推荐驱动（默认推荐驱动是 ``nvidia-driver-390`` ）::

   sudo ubuntu-drivers autoinstall

.. _set_ubuntu_wifi:

设置无线网络
================

.. note::

   推荐使用NetworkManager管理无线网络，现代主流Linux发行版，不论是 CentOS 7 还是 Ubuntu 18.0.4，默认都采用了NetworkManager来管理网络。详情请参考 `NetworkManager命令行nmcli <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/redhat/system_administration/network/networkmanager_nmcli.md>`_ 。

- 安装NetworkManager :ref:`ubuntu_packages_wifi` ::

   sudo apt install network-manager

- 启动NetworkManager::

   sudo systemctl start NetworkManager
   sudo systemctl enable NetworkManager

- 显示所有可以连接的访问热点（AP）::

   sudo nmcli device wifi list

- 新增加一个wifi类型连接，连接到名为 ``HOME`` 的AP上（配置设置成名为 ``MYHOME`` ）::

   nmcli con add con-name MYHOME ifname wlp3s0 type wifi ssid HOME \
   wifi-sec.key-mgmt wpa-psk wifi-sec.psk MYPASSWORD

- 指定配置 ``MYHOME`` 进行连接::

   nmcli con up MYHOME

- 新增加一个公司所用的802.1x认证的无线网络连接，连接到名为 ``OFFICE`` 的AP上（配置设置成 ``MYOFFICE`` ）::

   nmcli con add con-name MYOFFICE ifname wlp3s0 type wifi ssid OFFICE \
   wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 \
   802-1x.identity "USERNAME" 802-1x.password "MYPASSWORD"

- 执行连接（例如，使用配置 ``MYOFFICE`` ）::

   nmcli con up MYOFFICE

- 开启或关闭wifi::

   sudo nmcli radio wifi <on|off>

.. note::

   ``nmcli`` 指令有很多缩写的方法，只要命令不重合能够区分，例如 ``connection`` 可以缩写成 ``con`` 。

安装Xfce4桌面(可选)
========================

.. note::

   实际上在部署云计算模拟仿真集群测试环境是不需要安装图形桌面的，不过，考虑到MacBook Pro的Retina屏幕可以作为桌面工作的第二块屏幕，所以我还是安装了图形桌面，并通过Syngrey :ref:`share_mouse_keyboard` 。

   `Manjaro LXDE vs XFCE讨论 <https://forum.manjaro.org/t/manjaro-lxde-vs-xfce/48738/6>`_ 提供了不同桌面内存的占用对比。`LXDE vs Xfce这篇blog <http://mygeekopinions.blogspot.com/2011/08/lxde-vs-xfce.html>`_ 对比了两种轻量级平台的软件差异。

`Xfce4 <https://xfce.org>`_ 是我使用过较好兼容GTK（也就是Gnonme底层库）程序的轻量级桌面

- 最小化安装Xfce4 GUI环境::

   sudo apt install xfce4

.. note::

   如果之前已经安装过其他桌面，只想安装一个最精简的Xfce4环境（复用其他桌面的终端程序浏览器等），可以添加 ``--no-install-recommends`` 参数。如果要转换成类似Xubuntu的完整桌面环境，可以使用 ``apt install xfce4-desktop`` 。

- 可能需要补充安装(参考 `Xfce 4.12 Documentation <https://docs.xfce.org>`_ )::

   #电源管理、终端
   sudo apt install xfce4-power-manager \ 
   xfce4=terminal

.. note::

   另外也推荐使用轻量级桌面 `LXDE <https://lxde.org>`_ 

- 安装 ``xinit`` (包含 ``startx`` 以及 ``xserver-xorg-XXX``  ）::

   sudo apt install xinit

默认字符终端+startx
---------------------------

- 如果要尽可能节约系统资源，可以默认先进入字符终端，仅在需要时启动图形界面::

   sudo systemctl set-default multi-user.target

- 编辑 ``~/.xinitrc`` 添加::

   # 如果要启动Budgie
   #export XDG_CURRENT_DESKTOP=Budgie:GNOME
   #exec budgie-desktop
   
   # 如果要启动Xfce
   exec startxfce4

- 启动桌面::

   startx

.. note::

   遇到一个奇怪的问题，当退出Xfce4桌面时，屏幕是全黑，并没有返回到字符终端。此时主机实际上工作正常，远程ssh连接依然工作，可以正常远程操作主机。从合上笔记本屏幕，再次打开完全黑屏无响应看，似乎和电源管理有关。 :ref:`ubuntu_hibernate`

   系统日志显示确实进入了suspend的睡眠状态

默认启动X
----------------

- 如果要默认启动X，需要安装一个Display Manager，例如SLiM::

   sudo apt install slim

.. note::

   参考 `What is gdm3, kdm, lightdm? How to install and remove them? <https://askubuntu.com/questions/829108/what-is-gdm3-kdm-lightdm-how-to-install-and-remove-them>`_ 通常发行版会选择LightDM作为显示管理器。不过，LightDM安装依赖非常多（所以和各个桌面切换结合完美)，我倾向于选择SLiM。(参考 `What is the best Linux Display Manager? <https://www.slant.co/topics/2053/~best-linux-display-manager>`_ )


调整xfce4桌面
------------------

- ``Settings => Appearance`` 

  - 选择 ``Xfce-flat`` 作为 Style 
  - 选择 ``Humanity-Dark`` 作为 Icons（这样窗口按钮具有现代的扁平化风格，并且图标色彩艳丽）
  - Fonts 从默认的10号修改成13号（解决Retina屏幕字体过小)
  - ``重要关键`` : 一定要取消掉Fonts面板中的 ``DPI: Custom DPI Setting`` 选项，这个选项默认是 ``DPI=96`` ，这会导致在Retina屏幕上的菜单和文件管理器中显示的字体放大极为丑陋（这个字体是根据屏幕像素密度计算的，不能直接调整）

- ``Settings => Preferred Applications`` 需要设置终端使用 ``xfce-termianl``

  - ``xfce-termianl`` 设置Preferences中，Colors我选择Presets中的 ``Tango`` 色彩比较柔和

.. note::

   如果要简化美化步骤，或许可以直接借用Xubuntu设置，即执行 ``sudo apt install xubuntu-default-settings`` 安装。
