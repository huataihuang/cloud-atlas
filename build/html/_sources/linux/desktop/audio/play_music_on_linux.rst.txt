.. _play_music_on_linux:

=====================
在Linux环境播放音乐
=====================

我倾向于使用轻量级操作系统，所以使用音乐播放软件也以功能简洁为主。目前工作平台采用 :ref:`sway` 图形管理平台，采用 :ref:`kali_linux` for ARM，在日常工作中，以简单播放mp3和flac格式音乐为主。

mpd
======

大多数音乐客户端实际上是 ``mpd`` 客户端，通过 ``mpd`` 可以实现网络服务的音乐流，客户端可以按需选择。

audacious
============

audacious是GNOME平台默认音乐播放器，轻量且功能完备

目前我暂时没有解决 :ref:`pulseaudio` 配置，所以采用修改 ``Output`` 设备，直接选择 :ref:`alsa` ，即 ``Output Settings => Output plugin: ALSA Output`` 中配置 ``PMC device: hw:0,0 - bcm2835 HDMI 1`` 。配合我的AOC显示器自带的音频3.5"音频输出，可以正常工作，但是有背景杂音。是否可以继续改善待探索...

ncmpcpp
=============

ncmpccp是字符终端的 ``mpd`` 客户端，可以说最为轻量级且功能够用

cantata
=========

cantata是QT5的音乐播放器，支持lyrics歌词，且操作方便，也是 ``mpd`` 客户端。不过，2022年3月， `CDrummond/cantata <https://github.com/CDrummond/cantata>`_ 宣布经过10年开发，该项目已经停止，最后relase版本是 v.2.5.0 。


参考
=======

- `Working with Wayland and Sway <https://grimoire.science/working-with-wayland-and-sway/>`_
