.. _pi_4b_4k_display:

=========================
Raspberry Pi 4B的4K显示
=========================

在 :ref:`pi_400_4k_display` 实践中，我尝试使用Raspberry Pi 400来实现一个能够使用4K显示器的工作平台。但是，实践发现Raspberry Pi 400没有实现60Hz刷新率的4K输出(至少目前我实践没有成功)。不过，既然我有3台Raspberry Pi 4B，硬件架构和Raspberry Pi 400几乎完全一致，所以我把TF卡从 ``pi-master1`` 和 ``pi400`` 互换，将2GB规格的Raspberry Pi 4B连接到4K显示器上作为工作桌面。

树莓派4B实现4K@60Hz要点
========================

树莓派4B的显示核心硬件支持4K@60Hz，但是默认Raspberry Pi OS没有启用这个设置，主要是为了降低内存消耗和设备温度 - 参考 `Video options in config.txt <https://www.raspberrypi.org/documentation/configuration/config-txt/video.md>`_ 。

启用 4K@60Hz 设置需要注意以下要点:

- 只有一个视频输出接口支持 4K@60Hz - ``microHDMI-0`` ，这个显示接口靠近USB type C电源接口
- 必须使用高速HDMI视频线，至少要求 ``HDMI 2.0`` 线缆
- 显示器必须能够支持4K

.. note::

   通过 ``raspi-config`` 交互设置可以通过::

      Advanced Options => HDMI / Composite => Enable 4Kp60 HDMI Enable 4Kp60 resolution on HDMI0

   激活 4K@60Hz ，不过这个配置仅添加了 ``hdmi_enable_4kp60=1`` 配置。实践发现还需要关闭 ``dtoverlay=vc4-fkms-v3d`` 

   可选设置 ``Resolution => CEA Mode 97 3840x2160 60Hz 16:9`` ，实际不设置也会保持这个显示分辨率。

配置完成后通过以下命令检查连接设备和显示分辨率模式::

   tvservice -l

   tvservice -s

配置4K@60Hz
=============

.. warning::

   我实测下来在树莓派4B上还是无法同时启用 ``hdmi_enable_4kp60=1`` 和 ``dtoverlay=vc4-fkms-v3d`` ，一旦同时启用这两个配置就会导致字符终端启动过程就转为黑屏。

树莓派4B启用4K@60Hz方法
--------------------------

经过我的实践验证，参考 `Fake KMS and 4K60 cannot co-exist <https://github.com/raspberrypi/firmware/issues/1392>`_ 配置建议，在树莓派4B上配置 ``/boot/config.txt`` 如下::

   [pi4]
   # 启用 4kp60 不能启用 vc4-fkms-v3d
   #dtoverlay=vc4-fkms-v3d
   max_framebuffers=2

   [all]
   hdmi_enable_4kp60=1

然后重启就可以实现 4K@60Hz ，不过这个模式下在 :ref:`xfce` 桌面下检查会发现只有一个分辨率和刷新率可以选择，即固定为 ``3840x2160`` ``60Hz``

尝试记录
----------

通过 ``raspi-config`` 配置工具启用 ``4K@60Hz`` ，即在 ``/boot/config.txt`` 中添加以下配置::

   hdmi_enable_4kp60=1

重启Raspberry Pi 4B，果然看到了启动时字符显示高分辨率。但是，很不幸，启动服务显示过后，屏幕突然转黑，并且显示器显示没有信号。

我通过ssh登陆到系统，检查系统 ``dmesg`` 显示::

   [drm:drm_atomic_helper_wait_for_flip_done [drm_kms_helper]] *ERROR* [CRTC:87:crtc-0] flip_done timed out

这个问题是因为 `Fake KMS and 4K60 cannot co-exist <https://github.com/raspberrypi/firmware/issues/1392>`_

`Cannot set 60Hz @4k with Raspi 4B <https://raspberrypi.stackexchange.com/questions/104533/cannot-set-60hz-4k-with-raspi-4b>`_ 提供了一个解决思路，我尝试采用以下步骤：

- 在 ``/boot/config.txt`` 配置了 ``hdmi_enable_4kp60=1`` 同时添加以下行配置 ``4K30`` ::

   hdmi_group=1
   hdmi_mode=95
   hdmi_enable_4kp60=1

- 这样再次重启时候字符终端就是 ``4K@30Hz``

- 在主机上启动VNC，然后通过远程VNC访问桌面。此时在桌面上撇着显示刷新率 ``60.00Hz`` ，这时就能够在显示器上看到正常图形输出了

- 不过，此时TTY1到TTY6还没有输出信号，所以修改 ``config.txt`` 配置::

   hdmi_group=1
   hdmi_mode=16

上述模式是 ``1080p60`` 也就是字符终端不要设置4K，同时保持图形界面 4K@60Hz。

参考
======

- `HowTo: Enable video 4k@60Hz on Raspberry Pi 4 <https://blog.codetitans.pl/post/howto-enable-4k60hz-on-raspberry-pi-4/>`_
- `Cannot set 60Hz @4k with Raspi 4B <https://raspberrypi.stackexchange.com/questions/104533/cannot-set-60hz-4k-with-raspi-4b>`_
