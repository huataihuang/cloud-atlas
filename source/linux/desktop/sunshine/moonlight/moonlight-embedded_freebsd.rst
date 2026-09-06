.. _moonlight-embedded_freebsd:

====================================
FreeBSD平台安装Moonlight-Embedded
====================================

环境
======

我的 :ref:`freebsd` 运行在 :ref:`thinkpad_x220` 的 :ref:`sway` 桌面，纯 :ref:`wayland` 环境，所以为了追求完全轻量化，采用 :ref:`moonlight-embedded` 。

安装
=======

FreeBSD的 ``pkg`` 中只有 ``moonlight-qt`` (依赖了QT库，过于复杂沉重)，所以需要通过 :ref:`freebsd_ports` 从源代码编译。

.. literalinclude:: moonlight-embedded_freebsd/make
   :caption: 编译moonlight-embedded

这时会弹出交互界面让你选择编译参数:

.. figure:: ../../../../_static/linux/desktop/sunshine/moonlight/moonlight-embedded_make.png

这里的设置需要按照实际情况进行调整:

- ``[ ] X11`` -> 取消勾选: 我的目标是利用 KMS/DRM 直连显卡，或在 Sway (Wayland) 中运行。取消 X11 选项可以彻底剔除 Xorg 相关的大量臃肿依赖，使编译出的二进制包保持极简轻量。
- ``[ ] CEC`` -> 保持取消: ``HDMI-CEC`` 是电视遥控器控制协议。电脑内置屏幕或标准显示器接口不需要此功能，开启只会额外增加 ``libcec`` 依赖。
- ``(*) PULSE`` 或 ``(*) OSS`` -> 根据音频架构二选一: 在纯 TTY 字符界面下直连声卡、不依赖任何后台音频服务，保持默认的 OSS 即可（FreeBSD 内核原生支持）。此外， :ref:`sway` 桌面也可以直接使用OSS。不过，如果系统安装过firefox，则也具备了 PipeWire / PulseAudio 管理音频能力，也可以选择PULSE。

.. warning::

   编译过程需要从github下载文件，但是会被长城防火墙阻塞。所以需要 :ref:`freebsd_ports_proxy`

参考
=====

- gemini
