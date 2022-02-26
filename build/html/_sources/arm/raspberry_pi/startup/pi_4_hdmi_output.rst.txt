.. _pi_4_hdmi_output:

=====================
树莓派4的HDMI输出
=====================

视频性能
============

可以通过 ``raspi-config`` 设置为GPU配置更多内存来提升图形性能，这个设置对于将树莓派作为桌面使用很有帮助。例如，可以为GPU配置 256MB 内存。

配置后，在 ``/boot/config.txt`` 中，会增加如下配置::

   [all]
   gpu_mem=256

始终输出到HDMI
===============

我在使用 :ref:`pi_400` 作为桌面电脑时，遇到一个困扰，就是当显示器仅插在一个HDMI上(一共有2个HDMI)，则启动时终端开始输出在显示器上，但是启动结束后会自动切换到另外一个HDMI上，导致连接的屏幕没有显示。

这个解决方法，我采用了 ``always-on HDMI`` 设置解决，即修订 ``/boot/config.txt`` 配置::

   hdmi_force_hotplug=1

这样启动后树莓派会一直在HDMI上有视频输出，避免了终端字符屏幕进入黑屏。

.. warning::

   以上配置设置我实践过，但下文配置因为我暂时没有需求，暂时没有实践，仅做记录。后续有机会再实践...

关闭HDMI
===========

如果要节约电能，可能需要关闭HDMI输出，此时可以执行以下命令关闭::

   /usr/bin/tvservice -o

对于服务器可以在 ``/etc/rc.local`` 上添加，以便每次启动时关闭HDMI输出。

要重新激活HDMI输出，则执行::

   /usr/bin/tvservice -p

避免终端黑屏
================

当系统启动到字符界面，默认情况下，过一段时间就会进入黑屏节能。要避免屏幕黑屏，可以在 ``/etc/rc.local`` 的 ``exit 0`` 行之前插入以下命令禁止屏幕黑屏::

   setterm -blank 0 -powerdown 0 -powersave off

避免屏幕保护
================

如果没有鼠标和键盘接到树莓派上，但是你需要屏幕一直工作以便显示内容，则可以禁止屏幕保护。方法如下:

- 首先安装以下软件包::

   sudo apt-get install x11-xserver-utils

- 编辑 ``/etc/xdg/lxsession/LXDE/autostart`` 取消以下注释::

   @xscreensaver -no-splash

- 然后添加以下内容::

   @xset s off
   @xset -dpms
   @xset s noblank

使用HDMI输出声音
===================

对于使用HDMI同时具备喇叭的显示器，你可能想通过HDMI输出声音，以便能够通过显示器上的喇叭发声。可以通过 ``raspi-config`` 配置声音输出通道，也可以直接修订 ``/boot/config.txt`` 

- 默认配置可能是::

   hdmi_drive=1

这表示DVI模式(没有声音)，将上述配置修改成 ``2`` 即::

   hdmi_drive=2

这样就会使用 HDMI 输出(声音)

.. note::

   我使用 :ref:`pi_400` 没有提供声音输出的 ``3.5 mm`` 音频插孔，不过 :ref:`pi_400_4k_display` 采用AOC U28P2U/BS 28英寸4K显示器，提供了``3.5 mm`` 音频插孔，也就是树莓派可以通过HDMI输出声音到显示器，然后通过显示器的音频输出孔连接外部音响或耳机。

   所以，需要设置上述 ``hdmi_drive=2`` 配置

参考
======

- `HDMI output <https://mlagerberg.gitbooks.io/raspberry-pi/content/3.4-HDMI-output.html>`_
