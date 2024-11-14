.. _gentoo_alsa:

====================
Gentoo ALSA
====================

``ALSA`` 意思是 Advanced Linux Sound Architecture。以下是我的 Gentoo Linux 实践，以完成类似之前在 :ref:`arch_linux` 平台完成的 :ref:`linux_audio` 配置部署。

安装
======

硬件检测
---------

- 首先需要检测音频控制器，使用 ``lspci`` 完成检查:

.. literalinclude:: gentoo_alsa/lspci
   :caption: 使用 ``lspci`` 检测声卡硬件

我的 :ref:`mba13_early_2014` 输出显示是Intel HD声卡:

.. literalinclude:: gentoo_alsa/lspci_output
   :caption: 使用 ``lspci`` 检测声卡硬件显示案例: Intel HD声卡

`soundcard >> Intel Corporation Haswell-ULT HD Audio Controller (rev 09)  <https://h-node.org/soundcards/view/en/1543/Intel-Corporation-Haswell-ULT-HD-Audio-Controller--rev-09>`_ 有详细的 ``lspci`` 检查方法可以参考:

.. literalinclude:: gentoo_alsa/lspci_detail
   :caption: 使用 ``lspci -nnk`` 检查

输出可以看到内核驱动使用了 ``snd_hda_intel`` :

.. literalinclude:: gentoo_alsa/lspci_detail_output
   :caption: 使用 ``lspci -nnk`` 检查
   :emphasize-lines: 4,9

内核
-----------

激活以下内核配置选项:

.. literalinclude:: gentoo_alsa/sound_kernel
   :caption: 内核激活声卡支持

说明:

- ``Open Sound System (OSS)`` 已经被 ``ALSA`` 取代，所以我去除了 ``Preclaim OSS device numbers`` 配置

软件
--------

使用全局 ``alsa`` USE flag 可以激活软件包的ALSA支持，并且自动下载 ``media-libs/alsa-lib`` (默认在 ``x86`` 和 ``amd64`` desktop profiles)

.. note::

   ``flac`` 需要 ``ogg`` USE flag，所以我同时还启用了 ``ogg``

然后执行修改USE flags之后的重新更新系统:


.. literalinclude:: gentoo_use_flags/rebuild_world_after_change_use
   :caption: 在修改了全局 USE flag 之后对整个系统进行更新

为了能够排查和测试声音系统，建议安装 ``media-soud/alsa-utils`` :

.. literalinclude:: gentoo_alsa/alsa-utils
   :caption: 安装 media-sound/alsa-utils

.. note::

   为了方便测试播放音乐，我安装了一个简单轻量级播放软件 `mpg123 <https://www.mpg123.de/>`_ (历史悠久持续开发的开源软件):

   .. literalinclude:: gentoo_alsa/mpg123
      :caption: 安装 ``mpg123``

   可以使用如下命令测试:

   .. literalinclude:: gentoo_alsa/mpg123_radio
      :caption: 使用 ``mpg123`` 测试音频流

配置
==========

- 用户权限: 默认情况下，本地用户就能够具有权限播放音频以及修改mixer levels。当要允许远程用户使用ALSA时，则用户需要位于 ``audio`` 。需要注意将用户添加到 ``audio`` 组就允许了用户直接访问设备，可能会破坏 ``multi-seat`` 系统的 ``fast-user-switching`` 或 sotware mixing，所以通常不建议添加用户到 ``audio`` 组。

- 首先找出数字输出设备(digital output device):

.. literalinclude:: gentoo_alsa/aplay
   :caption: 使用 ``aplay -l`` 检查设备

输出显示:

.. literalinclude:: gentoo_alsa/aplay_output
   :caption: 使用 ``aplay -l`` 检查设备，输出案例

.. note::

   默认情况下，ALSA会 mute 所有的通道，必须人工unmute才能正常输出声音。

.. _browser_pulseaudio_support:

浏览器需要 :ref:`gentoo_pulseaudio` 支持
===========================================

Firefox从版本52开始将PulseAudio设为硬性要求，并放弃了直接输出到ALSA的支持。所以现在编译firefox，需要启用 :ref:`gentoo_pulseaudio` 的 ``pulseaudio`` USE flag。并且chromium也有同样要求。这两种浏览器要么依赖 ``pulseaudio`` 来设置正确的采样率，要么在没有pulseaudio的情况下将采样率设置为48000作为声卡界的事实标准。所以，如果没有pulseaudio支持，只有采样率48000的音源才能正确播放。因此，请启用 ``pulseaudio`` 支持。

.. literalinclude:: gentoo_use_flags/rebuild_world_after_change_use
   :caption: 在修改了全局 USE flag 之后对整个系统进行更新

经过一番折腾(耗费了我两天时间)，在启用了 ``pulseaudio`` USE flags之后，使用 ``alsamixer`` 配置可以看到，默认的 default 音频设备成为 ``pulseaudio`` ，解除该音频设备的mute状态并调整好适当音量。此时firefox就能够正常播放视频，输出声音。并且在启用了 ``pulseaudio`` 之后， :ref:`sway` 的 ``waybare`` 会增加一个音量指示图标，可以显示当前声音设备状态，非常直观。

.. note::

   总之，启用 ``alas pulseaudio`` USE flags，对于桌面系统非常重要，切记。

服务
=============

- 使用 :ref:`openrc` 配置ALSA:

.. literalinclude:: gentoo_alsa/openrc
   :caption: 配置OpenRC启动ALSA

其他
=======

.. warning::

   还有很多有关 ``ALSA`` 的配置，涉及多应用程序使用声卡设备等高级设置，我没有具体实践，待以后有机会再尝试。请参考官方原文

参考
========

- `gentoo wiki: ALSA <https://wiki.gentoo.org/wiki/ALSA>`_
- `archlinux wiki: Advanced Linux Sound Architecture <https://wiki.archlinux.org/title/Advanced_Linux_Sound_Architecture#Set_the_default_sound_card>`_
