.. _sway_status_alpine:

===================================
Alpine Linux的Sway环境状态栏优化
===================================

在 :ref:`sway_config` 中完成对桌面空间极致利用之后，按照Gemini建议，定制一个针对 :ref:`alpine_sway_mba11_late_2010` 优化的状态栏:

- 脚本直接针对 Alpine Linux（使用 Linux 内核、 ``/proc`` / ``/sys`` 虚拟文件系统以及 OpenRC 下的标准命令）
- 每5秒获取一次状态

.. note::

   更为复杂和美观的的Sway状态栏可以采用 :ref:`waybar`

安装字体
========

- Alpine 官方仓库中包含了 Font Awesome:

.. literalinclude:: sway_status_alpine/install_font
   :caption: 安装Awesome字体

状态脚本
===========

- 配置 :ref:`alpine_linux` 专用脚本:

.. literalinclude:: sway_status_alpine/status.sh
   :language: bash
   :caption: ``~/.config/sway/status.sh``

.. note::

   - ``get_volume`` 参考 :ref:`sway_macbook_key_alpine` 安装 ``alsa-utils``
   - ``get_media`` 参考 :ref:`mpd_playerctl` 安装 ``playerctl``

     - **文本截断机制** : ``cut -c 1-20`` 防止曲名过长撑爆 11 寸 MBA 的窄屏状态栏
     - **条件输出** : 在没有播放音乐时， ``get_media`` 会自动返回空，不占用任何多余的面板位置

- 脚本执行权限:

.. literalinclude:: sway_status_alpine/chmod
   :caption: 设置脚本可执行

- 在终端直接运行 ``~/.config/sway/status.sh`` 确认终端能以每 5 秒输出一行类似 ``C:798MHz@38°C/0.01 | M:10% | F:2058RPM|W:75% | 🔋101% | 2026-09-11 15:37`` 文本

- 配置 ``~/.config/sway/config`` 将 ``status_command`` 指向脚本:

.. literalinclude:: sway_status_alpine/config
   :caption: ``~/.config/sway/config`` 配置 ``status_command``
   :emphasize-lines: 14

