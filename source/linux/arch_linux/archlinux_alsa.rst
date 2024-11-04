.. _archlinux_alsa:

=======================
Arch Linux ALSA声音系统
=======================

高级Linux声音架构(Advanced Linux Sound Architecture, ALSA)提供了内核驱动的声卡驱动，替代了最初的Open Sound System (OSS)。

对应内核声音设备却动，ALSA也捆绑了一个用户态的驱动库给应用程序开发者，这样就可以使用ALSA驱动的较高层API进行开发。这样就可以通过ALSA哭实现直接(内核)声音设备的交互。

安装和设置
===========

ALSA是Linux内核模块，不需要手工安装。udev会自动检测硬件设备并在启动时加载驱动，也就是声音设备已经就绪。但是，你的声卡可能无声，只是因为设备被静音了。

用户权限
---------

通常本地用户被允许播放音频和调整mixer级别。要允许远程用户使用ALSA，你需要将用户添加到 ``audio`` 组，但是，不建议这样做。

ALSA应用程序
--------------

- 安装应用软件包 ``alsa-utils`` ::

   pacman -S alsa-utils

.. note::

   amixer是一个shell命令用于修改声音设置，alsamixer则提供了基于ncurses的终端交互界面设置声音设备。

.. note::

   ALSA也提供了OSS兼容的支持(部分)，以便能够运行一些使用 ``/dev/dsp`` 设备的遗留程序。如果你需要运行使用 ``dmix`` 的OSS应用程序，则安装 ``alsa-oss`` 软件包，然后加载 ``snd-seq-oss`` ``snd-pcm-oss`` 和 ``snd-mixer-oss`` 内核模块来激活OSS模拟。

ALSA和Systemd
---------------

``alsa-utils`` 软件包提供了 ``systemd`` 配置但愿文件 ``alsa-restore.service`` 和 ``alsa-state.service`` ，这两个都是安装时自动安装和激活的：

- ``alsa-restore.service`` 在启动时读取 ``/var/lib/alsa/asound.state`` 然后写入上次关机时记录的值进行更新。
- ``alsa-state.service`` 会启动alsactl进入daemon模式以便持续跟踪和音量调整。

ALSA Firmware
----------------

``alsa-firmwar`` 软件包包含了哦一些声卡（如Creative SB0400 Audigy2)所需。

Unmuting
-----------
 
其实ALSA默认已经激活，但是有可能被mute了，所以可以通过以下方式激活：

- 使用amixer来unmute:

.. literalinclude:: archlinux_alsa/amixer_unmute
   :caption: 使用 ``amixer`` 将音频设备默认静音去除 ``unmute``

- 使用alsamixer来unmute::

   alsamixer

交互界面中，每个通道下 ``MM`` 表示mute， ``00`` 表示打开。使用 ``<-`` 和 ``->`` 切换到对应通道下，然后按下 ``m`` 按键进行切换。

MGEG-4 AAC
============

在使用 ``parole player`` 播放视频或者音频文件时，遇到报错提示::

   parole need MPEG-4 AAC decoder to play this file

我安装了 ``gst-libav`` 之后解决了这个问题。从 `Arcl Linux社区文档 - Codecs and containers <https://wiki.archlinux.org/index.php/Codecs_and_containers>`_ 看，对应不同的音频和视频，可能需要安装不同的解码器。

其中比较常用的是 ``gstreamer`` 。

参考
======

- `Arcl Linux社区文档 - Advanced Linux Sound Architecture <https://wiki.archlinux.org/index.php/Advanced_Linux_Sound_Architecture>`_
- `Arcl Linux社区文档 - Codecs and containers <https://wiki.archlinux.org/index.php/Codecs_and_containers>`_
