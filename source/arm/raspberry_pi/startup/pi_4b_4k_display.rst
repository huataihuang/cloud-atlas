.. _pi_4b_4k_display:

=========================
Raspberry Pi 4B的4K显示
=========================

在 :ref:`pi_400_4k_display` 实践中，我尝试使用Raspberry Pi 400来实现一个能够使用4K显示器的工作平台。但是，实践发现Raspberry Pi 400没有实现60Hz刷新率的4K输出(至少目前我实践没有成功)。

不过，既然我有3台Raspberry Pi 4B，硬件架构和Raspberry Pi 400几乎完全一致，所以我把TF卡从 ``pi-master1`` 和 ``pi400`` 互换，将2GB规格的Raspberry Pi 4B连接到4K显示器上作为工作桌面。

.. note::

   不过，Raspberry Pi 4B当时为了省钱，购买了入门规格2GB，所以不能运行大量的桌面程序。理想的架构是作为瘦客户端，把所有的计算都调度到 :ref:`arm_k8s` 来完成。甚至把重度应用调度到远程云服务器上运行的x86容器中运行。

架构
=======

配置4K@60Hz
=============

通过 ``raspi-config`` 配置工具启用 ``4K@60Hz`` ，即在 ``/boot/config.txt`` 中添加以下配置::

   hdmi_enable_4kp60=1

重启Raspberry Pi 4B，果然看到了启动时字符显示高分辨率。但是，很不幸，启动服务显示过后，屏幕突然转黑，并且显示器显示没有信号。

我通过ssh登陆到系统，检查系统 ``dmesg`` 显示::

   [drm:drm_atomic_helper_wait_for_flip_done [drm_kms_helper]] *ERROR* [CRTC:87:crtc-0] flip_done timed out

这个问题是可能是因为 `Fake KMS and 4K60 cannot co-exist <https://github.com/raspberrypi/firmware/issues/1392>`_

- 在 ``/boot/config.txt`` 配置了 ``hdmi_enable_4kp60=1`` 同时添加以下行配置 ``4K30`` ::

   hdmi_group=1
   hdmi_mode=95
   hdmi_enable_4kp60=1

- 这样再次重启时候字符终端就是 ``4K@30Hz`` 

- 在主机上启动VNC，然后通过远程VNC访问桌面。此时在桌面上撇着显示刷新率 ``60.00Hz`` ，这时就能够在显示器上看到正常图形输出了

- 不过，此时TTY1到TTY6还没有输出信号，所以修改 ``config.txt`` 配置::

   hdmi_group=1
   hdmi_mode=16

上述模式是 ``1080p60`` 也就是字符终端不要设置4K，同时保持图形界面 4K@60Hz


参考
======

- `Cannot set 60Hz @4k with Raspi 4B <https://raspberrypi.stackexchange.com/questions/104533/cannot-set-60hz-4k-with-raspi-4b>`_
