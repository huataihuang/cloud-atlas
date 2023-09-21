.. _ubuntu_server:

===================
Ubuntu Server
===================

安装
===========

.. warning::

   Ubuntu Server版本的安装是非常死板的，会抹掉整个磁盘，重新创建GPT磁盘分区表。所以，即使原先磁盘空闲空间，并且想保留>数据磁盘的分区也是不可能的。

- 最小化安装

最小化安装对于运行云计算平台OpenStack，以及兼顾一些日常工作已经足够。没有必要完整安装大量的应用软件。

软件包和shell
-----------------

- ``/etc/hosts`` 需要设置主机名反向解析(添加 ``xcloud`` )，否则会导致很多操作命令响应缓慢::

   127.0.0.1    localhost.localdomain    localhost xcloud
   # 如果有固定IP，则设置类似
   # 192.168.1.24  xcloud

- 设置sudo::

   echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

- 安装Server版本之后，有一些必要的软件包推荐安装:

.. literalinclude:: ubuntu_server/apt_install
   :language: bash
   :caption: 安装必要工具软件包

.. note::

   在安装 :ref:`ubuntu64bit_pi` 我发现对于Ubuntu Server版本，不需要安装桌面版常用但 ``NetworkManager`` 网络配置工具，而只需要使用内建的 :ref:`netplan` 就可以完成网络配置。这样可以轻量级运行，降低使用资源。

- 安装 ``oh my zsh`` ::

   sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

- ``oh my zsh`` 添加用户名和主机提示，在 ``~/.zshrc`` 最后添加一行::

   export PROMPT='%(!.%{%F{yellow}%}.)$USER@%{$fg[white]%}%M ${ret_status} %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'

- ``~/.screenrc`` ::

   #source /etc/screenrc
   altscreen off
   hardstatus none
   caption always "%{= wk}%{wk}%-Lw%{rw} %n+%f %t %{wk}%+Lw %=%c%{= R}%{-}"
   
   shelltitle "$ |zsh"
   defscrollback 50000
   startup_message off
   escape ^aa
   
   termcapinfo xterm|xterms|xs|rxvt ti@:te@ # scroll bar support
   term rxvt # mouse support
   
   bindkey -k k; screen
   bindkey -k F1 prev
   bindkey -k F2 next
   bindkey -d -k kb stuff ^H
   bind x remove
   bind j eval "focus down"
   bind k eval "focus up"
   bind s eval "split" "focus down" "prev"
   vbell off
   shell -zsh

配置静态IP
--------------

请参考 :ref:`netplan_static_ip` 配置服务器静态IP地址，如果采用多网卡bonding，则参考 :ref:`netplan_bonding`

串口通讯
------------

物理服务器通常支持串口管理，可以通过 :ref:`ipmi` 实现远程管理和维护，但是需要操作系统内核配置。编辑 ``/etc/default/grub`` 设置::

   GRUB_CMDLINE_LINUX="ipv6.disable=1 crashkernel=auto console=tty0 console=ttyS0,115200n8"

然后更新grub::

   update-grub

timezone
---------

安装完成Unbuntu Server会发现系统时钟不是本地时钟（东8区），这个解决方法是修改 ``/etc/localtime`` 这个软链接文件的指向::

   sudo unlink /etc/localtime
   sudo ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

完成后再使用 ``date`` 命令检查时间就是本地时间了。

.. _ubuntu_lts_hwe:

Ubuntu LTS Enablement Stacks
================================

Ubuntu LTS enablement（也称为 HWE 或 Hardware Enablement）stacks为Ubuntu LTS版本提供了较新的内核以及X支持。这些enablement stacks可以手工安装。

Ubuntu 18.04.2 以及更新的版本在Desktop版本提供了一个保持更新的内核以及X堆栈。服务器架构则默认采用GA内核，并提供了可选的增强内核。

安装HWE软件栈
------------------

安装HWE软件栈非常简单：

- Desktop版本安装HWE::

   sudo apt install --install-recommends linux-generic-hwe-18.04 xserver-xorg-hwe-18.04

- Server版本安装HWE::

   sudo apt-get install --install-recommends linux-generic-hwe-18.04

.. note::

   在Ubuntu 18.04 LTS上安装了HWE之后，可以看到内核版本从原先的 4.15.x 系列更改成了 4.18.x 系列，和当前的 Ubuntu 18.10 发行版相当。

   Ubuntu 18.04 LTS也可以安装 ``xserver-xorg-hwe-18.04`` 。

   实际安装了HWE之后，Ubuntu LTS版本和最新的Stable版本差别不大(内核和Xorg)。

.. note::

   参考： `LTS Enablement Stacks <https://wiki.ubuntu.com/Kernel/LTSEnablementStack>`_

无线网卡
==========

我在安装Ubuntu Server时，采用了一块USB网卡连接有线网络，这样可以完整把整个安装过程进行结束。安装完成之后，通过以下方式安装驱动::

   sudo apt-get update
   sudo apt-get --reinstall install bcmwl-kernel-source

设置合上笔记本屏幕
====================

在Server字符终端方式使用中，实际上都是通过远程登陆服务器方式维护，所以通常会合上笔记本屏幕。和桌面版 :ref:`ubuntu_hibernate` 不同，我期望合上笔记本时候不要休眠继续工作，所以配置 ``/etc/systemd/logind.conf`` 添加::

   HandleLidSwitch=ignore
   HandleLidSwitchDocked=ignore

.. note::

   不过，上述ignore配置不会关闭屏幕，所以还有一个参数 ``lock`` 可以在字符终端合上笔记本屏幕时自动关闭屏幕电源，可以更加节约电能，也降低了笔记本的热量。

然后重启 ``logind`` 服务::

   systemctl restart systemd-logind

这样就可以把笔记本合上屏幕，放置在办公桌角落静静使用。

不过上述设置并没有关闭笔记本屏幕（显示器），所以会导致消耗电能并且发热，解决的方法是执行如下命令::

   sudo sh -c 'vbetool dpms off; read ans; vbetool dpms on'

这样关闭屏幕之后，只要按回车键能够恢复屏幕使用。

字符终端关闭fbvesa
=====================

我感觉在服务器上启用fbvesa似乎价值不大，并且我反复遇到屏幕花屏问题，似乎是由于混合了设置hibernate休眠以及设置了kms相关。但是由于太多的配置修改，难以恢复到最初的纯净状态。后续再次安装模拟系统，我将完全采用最简单的字符终端模式，关闭fbvesa。

请参考 `How to disable the Linux frame buffer if it's causing problems <https://support.digium.com/s/article/How-to-disable-the-Linux-frame-buffer-if-it-s-causing-problems>`_ 关闭fbvesa驱动。

可能的方法（待验证）是修改 ``/etc/grub.d/10_linux`` ，将以下行::

   linux   ${rel_dirname}/${basename} root=${linux_root_device_thisversion} ro ${args}

修改成::

   linux   ${rel_dirname}/${basename} root=${linux_root_device_thisversion} ro ${args} nomodeset

然后重启系统。不过，当前我测试始终没有成功，似乎是因为安装了nvidia专用驱动导致。我尝试 `I do not know how to Add this thing video=vesafb:off vga=normal' <https://ubuntuforums.org/showthread.php?t=2357949>`_ 也没有成功。

安装Xfce4桌面(可选)
========================

.. note::

   默认安装桌面时使用的显卡驱动是 nouveau ，但是这个驱动性能不如官方闭源驱动。如果需要安装官方驱动，请参考 :ref:`ubuntu_desktop_nvidia`

.. note::

   实际上在部署云计算模拟仿真集群测试环境是不需要安装图形桌面的，不过，考虑到MacBook Pro的Retina屏幕可以作为桌面工作的 第二块屏幕，所以我还是安装了图形桌面，并通过 :ref:`synergy` 。

   `Manjaro LXDE vs XFCE讨论 <https://forum.manjaro.org/t/manjaro-lxde-vs-xfce/48738/6>`_ 提供了不同桌面内存的占用对比 。`LXDE vs Xfce这篇blog <http://mygeekopinions.blogspot.com/2011/08/lxde-vs-xfce.html>`_ 对比了两种轻量级平台的软件差>异。

`Xfce4 <https://xfce.org>`_ 是我使用过较好兼容GTK（也就是Gnonme底层库）程序的轻量级桌面

- 最小化安装Xfce4 GUI环境::

   sudo apt install xfce4

.. note::

   如果之前已经安装过其他桌面，只想安装一个最精简的Xfce4环境（复用其他桌面的终端程序浏览器等），可以添加 ``--no-install-recommends`` 参数。如果要转换成类似Xubuntu的完整桌面环境，可以使用 ``apt install xfce4-desktop`` 。

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

.. note::

   由于MacBook Pro的Retina屏幕分辨率极高，所以字符终端的字体非常细小。请参考 `Ubuntu修改TTY字符终端字体 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/ubuntu/system_administration/change_tty_console_font_size.md>`_ ::

    sudo dpkg-reconfigure console-setup

   建议选择字符集 ``Guess optimal character set`` 的字体 ``Terminus`` ，字体大小可选择 ``11x22`` 或 ``14x28`` 。

- 编辑 ``~/.xinitrc`` 添加::

   # 如果要启动Budgie
   #export XDG_CURRENT_DESKTOP=Budgie:GNOME
   #exec budgie-desktop

   # 如果要启动Xfce
   exec startxfce4

- 启动桌面::

   startx

.. note::

   实际上，完全手工在Ubuntu Server精简安装Xfce4非常麻烦，可能组件不全。所以如果要使用图形桌面还是直接使用Desktop版本以节约配置花费的实践。

   此外，在MacBook Pro上部署Server版本，字符界面 ``startx`` 启动桌面，但是退出黑屏，始终没有解决。

默认启动X
----------------

- 如果要默认启动X，需要安装一个Display Manager，例如SLiM::

   sudo apt install slim

.. note::

   参考 `What is gdm3, kdm, lightdm? How to install and remove them? <https://askubuntu.com/questions/829108/what-is-gdm3-kdm-lightdm-how-to-install-and-remove-them>`_ 通常发行版会选择LightDM作为显示管理器。不过，LightDM安装依赖非常多（ 所以和各个桌面切换结合完美)，我倾向于选择SLiM。(参考 `What is the best Linux Display Manager? <https://www.slant.co/topics/2053/~best-linux-display-manager>`_ )

   不过实践中遇到的问题较多

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
