.. _freebsd_xfce4:

==================
FreeBSD XFCE桌面
==================

.. note::

   目前我比较倾向于使用基于 :ref:`wayland` 的 :ref:`freebsd_sway` ，不过最近的实践配置存在问题(已解决)所以目前采用 :ref:`xfce` 以便简化桌面复杂度，专注于后端服务器开发运维。

- 安装Xorg:

.. literalinclude:: freebsd_xfce4/install_xorg
   :caption: 安装Xorg

并将自己加入 ``video`` 组:

.. literalinclude:: freebsd_wayland_sway/group_add_video
   :caption: 将 ``admin`` 用户加入 ``video`` 组(举例)

- :ref:`freebsd_nvidia-driver` 安装配置

.. literalinclude:: freebsd_nvidia-driver/install_nvidia
   :caption: 安装NVIDIA驱动

.. literalinclude:: freebsd_nvidia-driver/kld
   :caption: 配置启动时加载nvidia驱动

可选安装 ``nvidia-xconfig`` ，我实践发现如果没有为NVIDIA显卡创建 ``xorg.conf`` ，则启动XFce4时无法运行 :ref:`x_window` **不过这不是必须的，实际上可以手工配置**

.. literalinclude:: freebsd_nvidia-driver/install_nvidia-xconfig
   :caption: 安装nvidia-xconfig

如果没有采用上述的 ``nvidia-xconfig`` ，也可以参考 `HOWTO: Setup Xorg with NVIDIA'driver <https://forums.freebsd.org/threads/howto-setup-xorg-with-nvidias-driver.52311/>`_ 简单配置一个 ``/usr/local/etc/X11/xorg.conf.d/driver-nvidia.conf`` 就可以正常运行Xorg:

.. literalinclude:: freebsd_nvidia-driver/driver-nvidia.conf
   :caption: 配置一个 ``driver-nvidia.conf`` 引导Xorg正确使用NVIDIA驱动

- 安装XFCE:

.. literalinclude:: freebsd_xfce4/install
   :caption: 安装Xfce4

安装信息:

.. literalinclude:: freebsd_xfce4/install_output
   :caption: 安装Xfce4提示信息

软件包说明:

.. csv-table:: XFCE4软件包说明
   :file: freebsd_xfce4/xfce4_pkg.csv
   :widths: 30, 70
   :header-rows: 1

安装XFCE会依赖安装 ``dbus-daemon`` ，并且需要在系统中激活 D-BUS :

.. literalinclude:: freebsd_xfce4/dbus_enable
   :caption: 激活系统启动时启动dbus

- 安装 ``x11/lightdm`` (一个轻量级显示管理器，使用内存很少且快速):

.. literalinclude:: freebsd_xfce4/install_lightdm
   :caption: 安装 lightdm

安装lightdm的输出信息

.. literalinclude:: freebsd_xfce4/install_lightdm_output
   :caption: 安装 lightdm 输出信息

异常排查
===========

报错显示我的笔记本显卡太陈旧，只能使用  NVIDIA 470.xx 驱动，我安装了最新的 550.120 驱动启动时Xorg日志报错;

- 启动::

   startxfce4

报错，检查 ``/var/log/Xorg.0.log`` 有如下错误:

.. literalinclude:: freebsd_nvidia-driver/version_error
   :caption: 提示需要使用旧版470.xx，直接忽略了错误的高版本550驱动

原来我的显卡 ``NVIDIA GeForce GT 750M GPU`` 太古老了，已经被最新的 ``510.60.02`` 放弃支持了，需要回退到 ``NVIDIA 470.xx Legacy drivers`` 。难怪之前 :ref:`freebsd_sway` 和 :ref:`freebsd_hikari` 都失败了

参考 `NVIDIA Unix Driver Archive <https://www.nvidia.com/en-us/drivers/unix/>`_ 可以看到，对于 ``FreeBSD x86`` ，最新的 ``Latest Legacy GPU version (470.xx series)`` : 470.141.03

搜索一下，在FreeBSD仓库，则是 ``nvidia-driver-470-470.129.06`` (之前安装了最新的 ``nvidia-driver-510.60.02`` ):

.. literalinclude:: freebsd_xfce4/install_nvidia-deiver-470
   :caption: 安装 ``nvidia-driver-470``

然后重启系统，再次重试成功

结束X后黑屏
-----------

我遇到一个问题，就是启动 ``startxfce4`` 之后，结束会话会出现黑屏

- 检查显卡所在pci位置::

   # pciconf -l | grep vga
   vgapci0@pci0:1:0:0:  class=0x030000 rev=0xa1 hdr=0x00 vendor=0x10de device=0x0fe9 subvendor=0x106b subdevice=0x0130

则修改 ``/etc/X11/xorg.conf`` ::

   Section "Device"
       Identifier     "Device0"
       Driver         "nvidia"
       VendorName     "NVIDIA Corporation"
       # 添加以下这行
       BusID          "PCI:1:0:0"
   EndSection

添加 ``BusID`` 时候，不要在PCI 包含domain ID，也就是说 ``pci0:1:0:0`` 写成 ``PCI:1:0:0``

不过，仅仅上述修改还没有解决问题，真正解决问题是修订了 ``/etc/rc.conf`` ，将::

   kld_list="nvidia-modeset"

修改为::

   linux_enable="YES"
   dbus_enable="YES"
   hald_enable="YES"
   lightdm_enable="YES"
   kld_list="nvidia nvidia-modeset linux"

才解决: 现在启动时候就是 ``lightdm`` ，并且退出也能够正常回到窗口管理器。我感觉关键行是::

   dbus_enable="YES"
   hald_enable="YES"

因为在此之前我检查过 ``kldstat`` 输出，原本就已经加载了::

   linux
   nvidia
   nvidia-modeset

也就是说 ``kld_list`` 默认已经加载了

.. note::

   参考 `How To Fix No Screen Found Xorg Error On FreeBSD [Dual GPU] <https://nudesystems.com/how-to-fix-no-screen-found-xorg-error-on-freebsd/>`_ 和 `xorg fails to start on freebsd even after installing nvidia and drm-kmod <https://unix.stackexchange.com/questions/628919/xorg-fails-to-start-on-freebsd-even-after-installing-nvidia-and-drm-kmod>`_

不过，虽然解决了 :ref:`freebsd_nvidia-driver` 的版本问题，但是运行 :ref:`freebsd_sway` 和 :ref:`freebsd_hikari` 报错依旧

配置Greeter和LightDM
=======================

- 修改 ``/usr/local/etc/lightdm/lightdm.conf`` 启用::

   greeter-session = lightdm-gtk-greeter

- 修改 ``/etc/rc.conf`` 添加::

   lightdm_enable="YES"

参考
======

- `Install FreeBSD with XFCE and NVIDIA Drivers [2021] <https://nudesystems.com/install-freebsd-with-xfce-and-nvidia-drivers/>`_
- `FreeBSD Handbook: Chapter 8. Desktop Environments <https://docs.freebsd.org/en/books/handbook/desktop/>`_
