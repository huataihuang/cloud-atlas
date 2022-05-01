.. _pi_400_display_config:

======================
树莓派400图形显示配置
======================

树莓派的图形显示配置位于 ``/boot/config.txt`` ，通过 ``raspi-config`` 工具可以调整，也可以手工编辑。

基本配置
===========

- 树莓派启动最少需要4行配置::

   hdmi_force_hotplug=1
   hdmi_group=2
   #hdmi_mode=87
   hdmi_force_mode=1

  - ``hdmi_force_hotplug=1`` 设置树莓派即使没有检测到HDMI显示链接也要输出一个信号。这是因为一些显示器比较特殊，这样即使树莓派没有适配也能输出显示
  - ``hdmi_group=2`` 和 ``hdmi_mode=87`` 结合是激活自定义视频配置，即告诉系统不使用常规的1080p；而 ``hdmi_force_mode=1`` 则表明确定采用自定义

    - 详细配置参考 `树莓派官方config.txt说明 <https://www.raspberrypi.com/documentation/computers/configuration.html>`_
    - 我没有使用 ``hdmi_mode`` 是因为预定义配置不符合我的显示器，而是采用 ``hdmi_cvt`` 自定义，见下文

- 关闭屏幕周边的黑边::

   disable_overscan=1

一些显示器需要有一个黑边，则设置为 ``0`` ，不过通常是指电视机显示器。而对于计算机显示器则不需要。

- 如果使用 ``DVI`` 或 ``HDMI`` 显示器，如果出现显示闪烁，则可以尝试输出更强信号，如::

   config_hdmi_boost=7

不过，这个配置会被 :ref:`pi_4` 和 :ref:`pi_400` 忽略，虽然其他主版会使用这个参数来增强视频输出信号。默认值是 ``2`` 或者 ``5`` 。调整到 ``7`` 通常能够满足要求，如果视频电缆非常长，则可能最高配置到 ``11`` 

- 如果树莓派和显示器不能协商正确的设置，没有达到即插即用，则可以尝试 ``boot_delay`` 配置，强制系统启动时等待一些时间再启动内核，对于一些显示器就会有足够时间就绪::

   boot_delay=5

- 重要: 如果显示器支持音频，则配置以下设置使得音频能够路由到HDMI端口，这样可以通过显示器的音频输出(耳机或喇叭)::

   hdmi_drive=2

以上配置并没有实际配置显示分辨率，但是提供了基础。

显示分辨率
===========

- 自定义分辨率::

    hdmi_cvt=3840 2160 60 3 0 0 0

.. note::

   上述 ``hdmi_cvt`` 是根据显示器配置，详见 :ref:`pi_hdmi`

完整配置
==========

- 我的完整配置:

.. literalinclude:: pi_400_display_config/config.txt
   :language: bash
   :caption: 使用ACO 4K显示器的树莓派400完整config.txt

说明:

- :ref:`pi_400` 确实 ``不支持`` **4K@60Hz**

  - 根据 `树莓派官方config.txt#HDMI Configuration <https://www.raspberrypi.com/documentation/computers/configuration.html#hdmi-configuration>`_ 说明，只有 :ref:`pi_4` 支持在 ``HDMI0`` 显示接口支持 ``4K@60Hz`` ，并且说明当激活 ``4K@60Hz`` 时会增加能耗和增高树莓派温度。这应该就是官方限制 :ref:`pi_400` **不提供 4K@60Hz** 的原因，因为 :ref:`pi_400` 采用被动散热，并且官方提升了处理器主频，所以本身已经有很大的散热压力，所以 ``关闭 4K@60Hz`` 也情有可原。
  - 如果强行在 :ref:`pi_400` 配置 ``hdmi_enable_4kp60=1`` 实际也是无效的，因为配置了该参数时， :ref:`pi_400` 会自动关闭 ``HDMI0`` 接口的视频输出，实际只有 ``HDNI1`` 能够后显示输出，而 ``HDNI1`` 的显示输出最高只能支持 ``4K@30Hz``
  - 总之，在 :ref:`pi_400` 上还是需要去掉 ``hdmi_enable_4kp60=1`` : 去掉该参数至少能够保证 ``HDMI0`` 和 ``HDMI1`` 同时能够输出 ``4K@30Hz`` ，也就是能够支持双4K显示器

精简配置
----------

后来实践发现，设置 ``hdmi_cvt`` 似乎没有什么优势，虽然可以正常工作，但是实际上即使不设置树莓派启动也能正确识别显示器的分辨率，所以我改为简化配置(只激活 ``HDMI`` 音频输出)

.. literalinclude:: pi_400_display_config/config-simple.txt
   :language: bash
   :caption: 使用ACO 4K显示器的树莓派400 精简config.txt
   :emphasize-lines: 13

超频配置和 ``HDMI1`` 音频
-------------------------------

:ref:`pi_overclock` 时发现当显示器接在 ``HDMI0`` 时不能稳定工作(主机键盘无响应，图形界面不能输出)，但是接在 ``HDMI1`` 上则稳定输出视频信号。但是不知道为何， ``HDMI1`` 虽然能够视频输出，但是 ``alsamixer`` 显示这个 ``vc4-hdmi-1`` 声卡状态 ``This sound device does not have any controls`` 。似乎只有  ``HDMI0`` 才有音频输出！！！

参考 `Independent Sound HDMI0 and HDMI1 <https://forums.raspberrypi.com/viewtopic.php?t=249204>`_ 提到了 ``snd_bcm2835.enable_compat_alsa=0`` 内核参数是问题，需要设置成 ``snd_bcm2835.enable_compat_alsa=1`` ，这样才能使 ``udev`` 规则能够使用 ``seat1`` / ``hdmi1`` 。

我修订了 ``/boot/cmdline`` ，在最后添加 ``snd_bcm2835.enable_compat_alsa=1`` ，然后重启后发现，内核参数同时有::

   ... snd_bcm2835.enable_compat_alsa=0 ... snd_bcm2835.enable_compat_alsa=1

此时很神奇，声卡设备突然多出了::

   hw:CARD=b1,DEV=0
       bcm2835 HDMI 1, bcm2835 HDMI 1
       Direct hardware device without any conversions

这不就是之前在 kali linux 系统中看到的 HDMI1 设备么，而且可以在 ``mpd.conf`` 中指定 ``hw:CARD=b1,DEV=0`` 作为设备。

我将这个设备配置到 ``mpd.conf`` ，发现 ``mpd`` 运行不报错，但是 ``HDMI1`` 连接显示器的音频依然无声。

经过反复搜索，终于在 `HDMI 1 on Pi 4 doesn't have sound #1243 <https://github.com/raspberrypi/firmware/issues/1243>`_  找到解答:

这不是firmware bug:  ``amixer -q cset numid=3 2`` 会路由音频设备到一个输出接口。这里的 ``2`` 表示 ``HDMI`` 但是只代表 ``HDMI0`` 。需要使用命令 ``amixer -q cset numid=3 3`` 调用  ``HDMI1`` 。

果然，我在终端执行命令::

   amixer -q cset numid=3 3

然后就突然能够 ``HDMI1`` 的显示接口连接的AOC显示器的音频耳机中听到  :ref:`mpd` 输出的音乐

为了自动化这个过程，在内核传递了 ``snd_bcm2835.enable_compat_alsa=1`` 配置到 ``/boot/cmdline.txt`` ，再添加一个 ``/etc/udev/rules.d/77-hdmi.rules`` 内容如下::

   TAG=="seat", ATTR{id}=="b1", ATTR{number}=="2", SUBSYSTEM=="sound", KERNEL=="card2", ENV{ID_SEAT}="seat1"

这样就能使用 ``seat 1/hdmi1``

不过，我也发现了一个问题，就是播放音乐时候，会突然黑屏，然后过好久才能恢复，似乎这个路由是存在问题的。

此外 `Raspberry Pi sound <https://www.hydrus.org.uk/journal/rpi-sound.html>`_ 一文提供了音频设置的较好参考。

.. note::

   折腾太多时间，我暂时无法解决 :ref:`pi_overclock` 带来的问题:

   - 需要使用 ``HDMI1`` 作为视频输出接口
   - ``HDMI1`` 接口没有解决音频输出功能(或者说接近解决，但音频播放时视频输出中断)

参考
======

- `Using Weird Displays with Raspberry Pi  Everything Else <https://learn.adafruit.com/using-weird-displays-with-raspberry-pi/everything-else>`_
- `Adjust Resolution for Raspberry Pi <http://wiki.sunfounder.cc/index.php?title=Adjust_Resolution_for_Raspberry_Pi>`_
- `树莓派官方config.txt#HDMI Configuration <https://www.raspberrypi.com/documentation/computers/configuration.html#hdmi-configuration>`_
