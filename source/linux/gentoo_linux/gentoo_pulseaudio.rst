.. _gentoo_pulseaudio:

==========================
Gentoo PulseAudio
==========================

PulseAudio(也简称 ``PA`` )是一个多平台，开源声音服务器，提供了多个基于底层 :ref:`gentoo_alsa` 的一系列功能:

- 网络支持(P2P和服务器模式)
- 单个应用的声音控制
- 更好地跨平台支持
- 动态延迟调整，通常用于节能
- 插件模块

现代 :ref:`browser_pulseaudio_support` ，通过PulseAudio实现跨平台音频支持。

内核
======

安装
=======

和 :ref:`gentoo_alsa` 类似，在全局 ``/etc/portage/make.conf`` 中添加 ``pulseaudio`` USE flag

然后执行修改USE flags之后的重新更新系统:

.. literalinclude:: gentoo_use_flags/rebuild_world_after_change_use
   :caption: 在修改了全局 USE flag 之后对整个系统进行更新

参考
=======

- `gentoo linux wiki: PulseAudio <https://wiki.gentoo.org/wiki/PulseAudio>`_
