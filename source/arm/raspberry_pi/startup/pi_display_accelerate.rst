.. _pi_display_accelerate:

====================
树莓派显示加速
====================

在 :ref:`pi_400_4k_display` 和 :ref:`pi_4b_4k_display` 我们尝试激活 4K@60Hz 显示分辨率，涉及到有关显示加速的配置优化。从操作系统整体上加速显示，不仅有启动配置，也有桌面应用的加速。本文汇总相关设置，提供一个整体建议。

升级系统和安装系统库
======================

在调优系统之前，首先要将系统升级到最新::

   sudo apt update
   sudo apt dist-upgrade

- 安装必要库::

   sudo apt install libgles2-mesa libgles2-mesa-dev xorg-dev

配置显示
===========

- 使用 ``raspi-config`` 配置或直接修改 ``/boot/config.txt`` （树莓派3的32位系统) 或 ``/boot/firmware/usercfg.txt`` (树莓派4的64位系统) ::

   dtoverlay=vc4-fkms-v3d 
   max_framebuffers=2 
   gpu_mem=128 
   hdmi_enable_4kp60=1

上述配置中启用了开源 ``vc4-fkms-v3d`` 3D显示驱动(Fake KMS)，并且配置 129MB 内存给GPU内存管理。 ( 有关GPU需要预分配内存可以参考 `Raspberry Pi OS Memory options in config.txt <https://www.raspberrypi.org/documentation/configuration/config-txt/memory.md>`_ )

内存分离和CMA分配
===================

虽然我们配置了有多少内存分配给GPU，剩余内存分配给CPU，但是这个内存分配默认是动态的。为了能够提升性能，可以采用内存分离配置来优化。

.. note::

   不过，我现在在 :ref:`pi_400` 上使用 ``raspi-config`` 找不到 ``memory splitting`` 选项了。

- 可以手工修订 ``/boot/config.txt`` ::

   dtoverlay=vc4-fkms-v3d, cma-128

这里 ``cma-128`` 就是预分配给GPU内存量。

重启和检查
==========

重启系统通过以下命令检查3D驱动是否已经加载和工作::

   cat /proc/device-tree/soc/firmwarekms@7e600000/status
   cat /proc/device-tree/v3dbus/v3d@7ec04000/status

如果两个返回值都是 ``okay`` 则已经启用了硬件加速。如果结果是 ``disabled`` 则尝试其他 ``dtoverlay`` 选项，然后重启检查。

启用Firefox硬件加速
====================

需要注意，虽然系统硬件加速已经启用，但是Firefox或chromium默认是没有配置使用硬件加速。

- 在Firefox中地址栏输入 ``about:support`` ，然后检查 ``Compositing`` 配置项，如果是 ``Basic`` 就表明没有启用硬件加速

- 在Firefox中地址栏输入 ``about:config`` ，然后选择以下配置项::

   layers.acceleration.force-enabled

- 点击触发设置该值为 ``true`` ，然后重启Firefox。再次打开 ``about:support`` 页面，检查 ``Compositing`` 配置项是否是 ``OpenGL`` 的话就表明激活了硬件加速。

在使用上的感受区别就是，当滚动Firefox的WEB页面时，不再出现 ``Xorg`` 进程大量占用CPU资源情况(几乎不增加CPU)。

启用Chromium硬件加速
======================

Chromium硬件加速配置检查位于 ``chrome://gpu`` ，配置修改则在 ``chrome://flags`` 。

- 在 ``chrome://flags`` 中找到 ``Override software rendering list`` 将参数值从 ``Default`` 修改为 ``Enabled`` ，这样就覆盖了内建的软件渲染列表，并且在unsupported system configurations上激活了GPU加速。

- 在 ``chrome://gup`` 页面再次检查，就会看到 ``Hardware Protected Video Decode: Hardware accelerated``

VLC激活硬件加速
==================

在VLC软件的配置 ``Tools > Preferences`` 中的 ``Video`` 面板的 ``Video Settings > Output`` 中可以选择 OpenGL video output。

注意，如果VLC没有编译OpenGL支持，这该选项设置不会生效。

参考
=====

- `RPI4 & Ubuntu MATE - How to enable video acceleration <https://www.dedoimedo.com/computers/rpi4-ubuntu-mate-hw-video-acceleration.html>`_
