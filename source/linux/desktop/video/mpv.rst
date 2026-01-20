.. _mpv:

===================
mpv
===================

- ``mpv`` 是一个命令行视频播放软件，官方并不提供GUI。但是， ``mpv`` 在启动后会提供一个OSC(on-screen-controller)，此时可以通过鼠标控制播放，也就相同于提供了基本GUI操作
- ``mpv`` 有大量的第三方GUI程序，包括著名的 :ref:`macos` 平台 `IINA <https://iina.io/>`_ 以及众多基于Qt开发的播放器，如 ``SMPlayer``
- 在 :ref:`sway` 环境通常推荐采用 ``mpv`` :

  - mpv的GPU渲染器被认为是目前开源软件中画质和性能平衡最好
  - 由于mpv没有多余的边框和菜单栏，并且以键盘快捷键控制为主，特别适配sway这种平铺环境，能够完美融合
  - mpv采用了Unix的极简注意设计哲学，脚本驱动，CLI优先，能够结合 :ref:`yt-dlp` 一行命令播放几乎所有网页视频
  - 原生支持 :ref:`wayland` ，能够在Sway桌面流畅运行

由于是命令行播放器，所以为了方便使用，可以结合文件管理器来操作:

- :ref:`thunar`

另外，通过 :ref:`mpv_script` 能够优化和补齐没有GUI菜单的短板。

GUI
==========

参考
======

- `mpv FAQ <https://github.com/mpv-player/mpv/wiki/FAQ>`_
