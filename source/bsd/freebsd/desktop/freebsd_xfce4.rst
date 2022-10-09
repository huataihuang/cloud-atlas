.. _freebsd_xfce4:

==================
FreeBSD XFCE桌面
==================

.. note::

   目前我比较倾向于使用基于 :ref:`wayland` 的 :ref:`freebsd_sway` ，所以本文仅做记录备用，后续可能再做实践...

   不过，wayland也因为是比较新的图形技术，尚有很多传统图形程序没有移植支持，所以必要时可能还会使用XFCE4桌面

我在完成 :ref:`freebsd_nvidia-driver` 安装之后，尝试使用 :ref:`freebsd_sway` ，也会在后续实践中尝试本文XFCE4图形桌面:

- 安装XFCE::

   pkg install xorg xfce xfce4-goodies lightdm lightdm-gtk-greeter dbus

软件包说明:

.. csv-table:: XFCE4软件包说明
   :file: freebsd_xfce4/xfce4_pkg.csv
   :widths: 30, 70
   :header-rows: 1

- :ref:`freebsd_nvidia-driver` 安装配置

- 启动::

   startxfce4

报错，检查 ``/var/log/Xorg.0.log`` 有如下错误::

   [   676.058 ] (II) LoadModule: "glx"
   [   676.058 ] (II) Loading /usr/local/lib/xorg/modules/extensions/libglx.so
   [   676.059 ] (II) Module glx: vendor="X.Org Foundation"
   [   676.059 ]    compiled for 1.21.1.4, module version = 1.0.0
   [   676.059 ]    ABI class: X.Org Server Extension, version 10.0
   [   676.059 ] (II) LoadModule: "nvidia"
   [   676.059 ] (II) Loading /usr/local/lib/xorg/modules/drivers/nvidia_drv.so
   [   676.059 ] (II) Module nvidia: vendor="NVIDIA Corporation"
   [   676.059 ]    compiled for 1.6.99.901, module version = 1.0.0
   [   676.059 ]    Module class: X.Org Video Driver
   [   676.059 ] (II) NVIDIA dlloader X Driver  510.60.02  Wed Mar 16 11:07:20 UTC 2022
   [   676.059 ] (II) NVIDIA Unified Driver for all Supported NVIDIA GPUs
   [   676.059 ] (--) Using syscons driver with X support (version 2.0)
   [   676.059 ] (--) using VT number 9

   [   676.059 ] (II) Loading sub module "fb"
   [   676.060 ] (II) LoadModule: "fb"
   [   676.060 ] (II) Module "fb" already built-in
   [   676.060 ] (II) Loading sub module "wfb"
   [   676.060 ] (II) LoadModule: "wfb"
   [   676.060 ] (II) Loading /usr/local/lib/xorg/modules/libwfb.so
   [   676.060 ] (II) Module wfb: vendor="X.Org Foundation"
   [   676.060 ]    compiled for 1.21.1.4, module version = 1.0.0
   [   676.060 ]    ABI class: X.Org ANSI C Emulation, version 0.4
   [   676.060 ] (II) Loading sub module "ramdac"
   [   676.060 ] (II) LoadModule: "ramdac"
   [   676.060 ] (II) Module "ramdac" already built-in
   [   676.060 ] (WW) NVIDIA(0): The NVIDIA GeForce GT 750M GPU installed in this system is
   [   676.060 ] (WW) NVIDIA(0):     supported through the NVIDIA 470.xx Legacy drivers. Please
   [   676.060 ] (WW) NVIDIA(0):     visit http://www.nvidia.com/object/unix.html for more
   [   676.060 ] (WW) NVIDIA(0):     information.  The 510.60.02 NVIDIA driver will ignore this
   [   676.060 ] (WW) NVIDIA(0):     GPU.  Continuing probe...
   [   676.060 ] (EE) No devices detected.
   [   676.060 ] (EE)
   Fatal server error:
   [   676.060 ] (EE) no screens found(EE)
   [   676.060 ] (EE)

奇怪，已经加载 ``nvidia`` 模块，为何显示没有检测到设备... 仔细看了一下，原来我的显卡 ``NVIDIA GeForce GT 750M GPU`` 太古老了，已经被最新的 ``510.60.02`` 放弃支持了，需要回退到 ``NVIDIA 470.xx Legacy drivers`` 。难怪之前 :ref:`freebsd_sway` 和 :ref:`freebsd_hikari` 都失败了

参考 `NVIDIA Unix Driver Archive <https://www.nvidia.com/en-us/drivers/unix/>`_ 可以看到，对于 ``FreeBSD x86`` ，最新的 ``Latest Legacy GPU version (470.xx series)`` : 470.141.03

搜索一下，在FreeBSD仓库，则是 ``nvidia-driver-470-470.129.06`` (之前安装了最新的 ``nvidia-driver-510.60.02`` )::

   pkg delete nvidia-driver-510.60.02

   pkg install nvidia-driver-470-470.129.06

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
