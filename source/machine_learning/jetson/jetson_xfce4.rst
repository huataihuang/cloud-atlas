.. _jetson_xfce4:

=====================
Jetson转换Xfce4桌面
=====================

不知道为何NVIDIA Jetson nano默认的桌面是庞大而沉重的Gnome 3环境，这对仅仅4G内存的ARM系统来说是非常占用资源的。启动缓慢，操作经常卡顿。（不过，应该也和我使用较为慢速的SD卡有关)。

我的目标是类似在 :ref:`jetson_remote` 中所述，使用轻量级的Xfce4桌面替换沉重的Gnome 4，将更多的系统资源用于计算。

Xfce和Xubuntu区别
===================

有两种方式可以安装Xfce桌面：

- 安装 ``xfce4`` 软件包获得基本的Xfce4桌面
- 安装 ``xubuntu-desktop`` 软件包获得完整的Xubuntu体验

- 安装xfce4::

   sudo apt install xfce4

- 安装完整XUbuntu::

   sudo apt install xubuntu-desktop

在安装 xubuntu-desktop 时会提示选择 display manager ，可以选择 ``lightdm`` 获得更轻量级显示管理器。

.. note::

   我感觉 xubuntu 安装的软件包实在太多了，包含了大量的打印驱动，桌面插件甚至带上了firefox。而我实际上只需要非常简单的工作环境。所以，我最终只选择 ``xfce4`` 。

清理Unity
=========

Ubuntu自带的Unity是一个深度定制的Gnome3环境，对于我来说使用非常不便且占用资源。所以我在安装了xfce4之后，希望清理掉Unity。不过，这是一个具有风险的操作，

清理::

   sudo apt remove nautilus gnome-power-manager gnome-screensaver gnome-termina* gnome-pane* gnome-applet* gnome-bluetooth gnome-desktop* gnome-sessio* gnome-user* gnome-shell-common compiz compiz* unity unity* hud zeitgeist zeitgeist* python-zeitgeist libzeitgeist* activity-log-manager-common gnome-control-center gnome-screenshot overlay-scrollba* && sudo apt-get install xubuntu-community-wallpapers

安装lightdm显示管理器::

   sudo apt install lightdm

清理不需要的软件::

   sudo apt autoremove

lightdm登陆
------------

lightdm登陆时，虽然密码输入正确，但是提示 ``Failed to start session`` ，不过 :ref:`jetson_remote` 还能够正常工作。

导致 lightdm 无法登陆xfce4桌面的解决方法参考 `How to solve ‘Failed to start session’ with LightDM and Xfce <https://cialu.net/how-to-solve-failed-to-start-session-with-lightdm-and-xfce/>`_ ，原因是一些错误配置文件导致的，主要发生在Ubuntu Server上安装Xfce或者在Ubuntu上从一个旧的桌面版本切换到奥Xfce会话。

.. note::

   Ubuntu的LightDM是为Unity配置的，所以需要特别为Xfce配置LightDM。

- 删除 Unity配置文件::

   rm /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf

- 为LightDM创建Xfce配置文件 ``/usr/share/lightdm/lightdm.conf.d/50-xfce-greeter.conf`` 内容如下::

   [SeatDefaults]
   greeter-session=unity-greeter
   user-session=xfce

然后重启系统

.. note::

   使用lightdm，登陆桌面以后，观察 ``top`` 输出，我发现 ``/usr/sbin/unity-greeter`` 占用内存居然有105MB(lightdm)，占用了实际使用内存的1/7，让我非常无语。如果不是为了远程访问xrdp，或许还是从字符终端直接使用 ``startx`` 启动桌面比较节约内存。

- 如果希望禁止guest用户登陆并且启用自动登陆选项，添加以下行::

   allow-guest=false
   autologin-user=<your-username>
   autologin-user-timeout=0

移除xfce4
============

如果不再使用xfce4，则可以使用以下命令移除::

   sudo apt purge xubuntu-icon-theme xfce4-*
   sudo apt autoremove

如果是通过 xubuntu-desktop 软件包安装Xfce，则使用如下命令移除::

   sudo apt purge xubuntu-desktop xubuntu-icon-theme xfce4-*
   sudo apt purge plymouth-theme-xubuntu-logo plymouth-theme-xubuntu-text
   sudo apt autoremove

此外可以反向把lightdm回退到gdm3::

   sudo apt remove -y lightdm
   sudo apt install --reinstall -y gdm3
   sudo reboot

中文输入
==========

默认安装的Xfce4已经很好显示中文，字体也非常美观。和 :ref:`xfce` 一样安装fcitx中文输入法::

   #apt install fcitx fcitx-sunpinyin
   apt install fcitx-bin fcitx-googlepinyin

进入xfce4桌面，在终端运行 ``fcitx-configtool`` 命令提示输出::

   fcitx-configtool

在 ``Input Method Configuration`` 中点击 ``+`` 添加输入方法，注意需要去除 ``Only Show Current Language`` 的勾选，然后就可以选择 ``Google Pinyin`` 

- 传统的 ``fcitx`` 的图标比较简陋，可选安装新的UI::

   # Remove classic UI
   sudo apt remove fcitx-ui-classic
   # Install new UI
   sudo apt install fcitx-ui-qimpanel

- 需要修改 ``XMODIFIERS`` ，即在 ``~/.xinitrc`` 添加::

   export GTK_IM_MODULE=fcitx
   export QT_IM_MODULE=fcitx
   export XMODIFIERS=@im=fcitx

.. note::

   详细Xfce4设置请参考 :ref:`xfce`

参考
=====

- `Install Xfce Desktop on Ubuntu and Turn it Into Xubuntu <https://itsfoss.com/install-xfce-desktop-xubuntu/>`_
- `Ubuntu 19.04: Install Xfce for desktop environment <https://www.hiroom2.com/2019/06/13/ubuntu-1904-xfce-en/>`_
- `Fcitx Chinese Input Setup on Ubuntu for Gaming <https://leimao.github.io/blog/Ubuntu-Gaming-Chinese-Input/>`_
