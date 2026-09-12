.. _mpd_playerctl:

==========================
使用playerctl控制MPD
==========================

``mpd`` 本身是一个系统级后台服务，它使用自有的 ``MPD 协议``（ ``TCP 6600 端口`` ）进行通信，而 ``ncmpc`` 只是它的原生终端客户端，因此 ``mpd`` 原生并不直接提供 ``D-Bus MPRIS`` 接口。

只要在后台运行一个专为 ``MPD`` 设计的 ``MPRIS`` 桥接守护进程（例如 ``mpd-mpris`` ），就能将 ``MPD`` 的状态转换为 ``MPRIS`` 接口，从而让 ``playerctl`` 完美识别并控制 ``MPD`` / ``ncmpc`` 。

.. literalinclude:: mpd_playerctl/infra
   :caption: playerctl控制MPD原理

配置
=======

- :ref:`alpine_linux` 安装 mpd-mpris:

.. literalinclude:: mpd_playerctl/install
   :caption: 安装 mpd-mpris

- 在 Sway 中设置后台自启: 编辑 ``~/.config/sway/config`` ，添加 ``mpd-mpris`` 的后台自启指令

.. literalinclude:: mpd_playerctl/config
   :caption: ``~/.config/sway/config``

配置生效后，无论是否打开 ``ncmpc`` ，只要 ``MPD`` 在后台运行，就可以直接在终端或通过 Sway 快捷键执行以下命令:

.. literalinclude:: mpd_playerctl/play
   :caption: 控制mpd播放

另外，可以在 :ref:`sway_status_alpine` 增加通过 ``playerctl`` 提取播放状态与元数据（歌手和歌名）。

参考
======

- gemini
