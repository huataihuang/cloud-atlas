.. _pulseaudio:

===================
PulseAudio
===================

``PulseAudio`` 是通过freedesktop.org项目分发的网络音频服务器程序。主要在Linux和BSD系列操作系统（FreeBSD,OpenBSD,macOS)中使用，也有Solaris操作系统版本Illumos发行版使用。从原理上说， :ref:`alsa` 是 :ref:`kernel` 中提供声音硬件驱动的子系统，而 PulseAudio 则是应用程序和 ``ALSA`` 之间的接口。不过，现在这个模式不是强制的，不使用PulseAudio依然可以播音和混音。

PulseAudio作为一个声音服务器，在后台处理从一个或多个来源(处理器、捕捉设备等)输入的声音。PulseAudio的一个目的是重路由所有的声音流通过他，包括那些试图之际访问硬件的声音流。PulseAudio归档声音流来提供应用程序使用声音系统，例如aRts和ESD。在典型的Linux安装场景，通常用户配置ALSA来使用由PulseAudio提供的一个虚拟设备。这样应用程序使用ALSA就会输出声音到PulseAudio，再使用ALSA来访问实际的声卡。PulseAudio也提供自己原生接口给应用程序，以便应用程序直接支持PulseAudio，这种方式可以取代传统的ESD应用程序接口，以便取代ESD。对于OSS应用程序，PulseAudio也提供一个
``padsp`` 实用程序，取代了 ``/dev/dsp`` 设备文件，欺骗应用程序使其以为控制了声卡，实际输出是重定向通过PulseAudio。

PulseAudio在激活 ``Avahi`` 时可以提供一个易用的网络流，可以让高级用户能够配置服务来适合应用场景。

树莓派
=========

我在 :ref:`install_kali_pi` 发现系统运行了 ``pulseaudio`` 服务非常消耗资源，大约消耗了 10% 的CPU资源。虽然没有任何声音在播放，并且硬件设备 :ref:`pi_400` 没有提供直接声音输出口，我实际是采用 :ref:`mpd` 直接使用 :ref:`alsa` ，所以我在 :ref:`pi_400` 运行 :ref:`kali_linux` 配置关闭了 ``pulseaudio`` :

- 修改 ``/etc/pulse/client.conf`` ( 或 ``~/.pulse/client.conf`` ) 将::

   ; autospawn = yes

修改成::

   ; autospawn = no

参考
======

- `WikiPedia: PulseAudio <https://en.wikipedia.org/wiki/PulseAudio>`_
- `arch linux: PulseAudio <https://wiki.archlinux.org/title/PulseAudio>`_
- `PulseAudio on Linux <https://learn.foundry.com/nuke/content/timeline_environment/managetimelines/audio_pulse.html>`_
