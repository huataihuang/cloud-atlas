.. _pi_400_dual_monitor:

==============================
Raspberry Pi 400双显示器
==============================

我在 :ref:`pi_400` 上使用 :ref:`kali_linux` for Raspberry Pi，虽然没有 :ref:`pi_400_4k_display` ，但是最近找到了第2台2K显示器，也就是说我同时有2台2K HP显示器。我本来以为是即插即用，但是实践发现，即使连接好2台显示器，重启Raspberry Pi 400之后，也只有主显示器正常显示屏幕内容，第二台显示器则只有树莓派启动时标志性的 ``彩虹方块``
。这证明显示器硬件和连接线正常工作，但是软件设置不正确。

很多网上文档只介绍了使用图形操作系统的 ``Display`` 设置功能，但是我打开Kali Linux的 ``Display`` 设置，只能看到一个 ``General`` 面板中只有一个 ``default`` 配置项，甚至都没有检测出显示器厂商和型号。

排查
=========

- 检查是否能够检测出显示器::

   tvservice -l

可以看到有两个显示器::

   2 attached device(s), display ID's are : 
   Display Number 2, type HDMI 0
   Display Number 7, type HDMI 1

- 检查连接显示器状态

检查设备ID 2::

   tvservice -s -v 2

显示::

   state 0xa [HDMI CEA (16) RGB lim 16:9], 1920x1080 @ 60.00Hz, progressive

检查设备ID 7::

   tvservice -s -v 7

显示::

   state 0xa [HDMI CEA (16) RGB lim 16:9], 1920x1080 @ 60.00Hz, progressive

强制双显示器(供参考)
======================

.. note::

   我的问题不是检测不到第二个显示器，而是操作系统配置问题，所以并不需要强制设置显示器。这里的方法仅供参考。

- 将检测显示器数据输出到 ``edit.dat`` 文件::

   tvservice -d edid.dat

将输出的显示器信息文件 ``edit.dat`` 复制到启动目录::

   sudo cp edid.dat /boot/

- 编辑 ``/boot/config.txt`` 添加::

   hdmi_edid_file:1=1
   hdmi_edid_filename:1=edid.dat
   hdmi_force_hotplug:1=1


- 树莓派的PCI设备和常规PC不同，执行::

   lspci

可以看到以下2个设备::

   00:00.0 PCI bridge: Broadcom Inc. and subsidiaries BCM2711 PCIe Bridge (rev 20)
   01:00.0 USB controller: VIA Technologies, Inc. VL805/806 xHCI USB 3.0 Controller (rev 01)

解决方法
===========

原来要使用高级图形功能，特别是能够使用双显示器输出以及高分辨率显示器，必须要激活 :ref:`pi_display_accelerate` 

例如，在没有加载驱动之前，在树莓派上不能使用 ``xrandr`` (无法找到VGA设备)::

   xrandr

输出显示::

   Can't open display

并且，在 :ref:`xfce` 桌面中无法检测外接显示型号，即使显示器是2k显示器，也无法选择 ``2560x1440`` ，只能使用 ``1950x1080`` 所以非常模糊。

- 修改 ``/boot/config.txt`` ::

   dtoverlay=vc4-fkms-v3d
   max_framebuffers=2

然后重启系统后，就能在字符界面启动过程中看到同时输出到2个显示器，并且登录图形界面也能看到两个屏幕输出。

此时再使用 ``xrandr`` 就能够正常看到::

   HDMI-1 connected primary 2560x1440+0+0 (normal left inverted right x axis y axis) 597mm x 336mm
      2560x1440     59.95*+
      1920x1200     59.95  
      1920x1080     60.00    50.00    59.94  
      1600x1200     60.00  
      1680x1050     59.88  
      1600x900      60.00  
      1280x1024     60.02  
      1440x900      59.90  
      1280x720      60.00    50.00    59.94  
      1024x768      60.00  
      800x600       60.32  
      720x576       50.00  
      720x480       60.00    59.94  
      640x480       60.00    59.94  
      720x400       70.08  
   HDMI-2 connected 2560x1440+0+0 (normal left inverted right x axis y axis) 597mm x 336mm
      2560x1440     59.95*+
      1920x1200     59.95  
      1920x1080     60.00    50.00    59.94  
      1600x1200     60.00  
      1680x1050     59.88  
      1600x900      60.00  
      1280x1024     60.02  
      1440x900      59.90  
      1280x720      60.00    50.00    59.94  
      1024x768      60.00  
      800x600       60.32  
      720x576       50.00  
      720x480       60.00    59.94  
      640x480       60.00    59.94  
      720x400       70.08  

不过，还是非常奇怪，只能使用 ``mirror`` 显示模式，此时能够正常使用(高分辨率也行)，但是不能使用扩展屏幕，会导致显示只能使用部分屏幕。考虑到在没有登录到xfce4桌面之前，在登录界面(lxdm？)是可以正常显示，唯有登录后才会出现屏幕无法扩展问题，所以怀疑和xfce4有关。

测试(部分)成功
===============

通过不断尝试，我发现一个 ``workaround`` 的方法:

- ``第2个屏幕旋转90度`` : 第二个屏幕实际上是主屏幕，地一个屏幕是扩展屏幕。当第二个屏幕(主屏幕)旋转90度之后，神奇的能够完全正常显示屏幕，此时第一个屏幕也能完全正常扩展
- 我感觉就是因为扩展模式下，主屏幕无法达到 ``2560`` 宽度，但是可以达到 ``1440`` 宽度，所以旋转屏幕以后可以满足这个要求

显示设置效果如下:

.. figure:: ../../../_static/arm/raspberry_pi/startup/pi_400_dual_monitor_setting.png
   :scale: 80

此外，配置修订成以下 :ref:`pi_display_accelerate` ::

   dtoverlay=vc4-fkms-v3d, cma-128
   max_framebuffers=2
   gpu_mem=128

不过，我发现系统日志有报错(待查)::

   [Wed Nov 24 15:10:41 2021] v3d fec00000.v3d: MMU error from client CLE (4) at 0x244c1000, pte invalid
   [Wed Nov 24 15:33:23 2021] [drm:vc4_bo_create [vc4]] *ERROR* Failed to allocate from CMA:
   [Wed Nov 24 15:33:23 2021] vc4-drm gpu: [drm]                           dumb: 130168kb BOs (12)

参考
=========

- `Raspberry Pi 4 Dual Monitors <https://forums.raspberrypi.com/viewtopic.php?t=244558>`_
- `How can I get my Raspberry pi to run Dual monitor running ubuntu <How can I get my Raspberry pi to run Dual monitor running ubuntu>`_
