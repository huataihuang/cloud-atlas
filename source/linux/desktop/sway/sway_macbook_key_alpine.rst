.. _sway_macbook_key_alpine:

=======================================
sway桌面配置MacBook按键(Alpine Linux)
=======================================

在MacBook上都有一排快捷功能键，如果能够结合到 :ref:`sway` 的 ``bindsym`` 快捷键配置中，就能帮助实现直观的控制功能:

- 音量调节
- 屏幕亮度调节
- 媒体播放控制

怎么能够找到按键的对应字符串呢？方法类似X Window的 ``xev`` 工具，使用面向 :ref:`wayland`  的 :ref:`wev` 即可。

从 ``wev`` 获得以下字符串:

.. literalinclude:: sway_macbook_key/macbook_key
   :caption: 通过 ``wev`` 工具获得的MacBook功能键对应字符串

结合Sway默认配置
======================

.. warning::

   实际上sway的配置模板中默认就包含了控制音量、媒体播放和屏幕亮度的配置，分别依赖 ``pipewire`` , ``playerctl`` 和 ``brightnessctl`` ，所以如果要开箱即用，只需要安装对应软件包就可以。

- 检查 ``~/.config/sway/config`` 就可以看到如下关于控制音量、媒体播放和屏幕亮度的配置:

.. literalinclude:: sway_macbook_key_alpine/config_default
   :caption: 默认的sway配置中包含的控制快捷键

也就是说，只需要在系统中安装对应的控制命令(及依赖)就可以完美实现控制:

.. literalinclude:: sway_macbook_key_alpine/install_default_controller
   :caption: 安装控制快捷键的默认依赖命令和软件包

.. _playerctl:

playerctl
-----------

``playerctl`` 是一个专为 Linux/Unix 桌面环境设计的命令行媒体播放器控制工具。

``playerctl`` 依赖的核心机制: **MPRIS D-Bus 接口**

playerctl 本身不具备播放音频的能力，也不直接操作声卡，它完全依赖于 Linux 下的 MPRIS (Media Player Remote Interrogation and Control) 规范与 D-Bus（跨进程通信机制）。

- D-Bus (Desktop Bus) 进程间通信: D-Bus 是 Linux 桌面环境中用于不同程序之间相互发消息、传递数据的总线通道。

  - 客户端 (Client)：playerctl
  - 服务端 (Server)：各类播放器（如 VLC, MPV, Spotify, Rhythmbox, 甚至是 Chrome/Firefox 浏览器）

- MPRIS 2.0 协议规范

MPRIS 是 Freedesktop 制定的一套基于 D-Bus 的标准接口协议。只要播放器实现了 MPRIS 规范，它就会在系统的 D-Bus 会话总线（Session Bus）上注册一个形如 ``org.mpris.MediaPlayer2.<播放器名称>`` 的服务节点，并暴露标准的控制 API（如 ``Play()`` , ``Pause()`` , ``Next()`` ）和数据属性（如 ``Metadata`` ）。

``playerctl`` 使用要点:

- 必须运行 D-Bus 会话总线: ``playerctl`` 执行时需要知道 ``D-Bus`` 会话地址。通常需要确保系统安装并启动了 ``dbus`` ，且在启动 Sway 时使用了 ``dbus-run-session sway`` 或在环境变量中导出了 ``DBUS_SESSION_BUS_ADDRESS`` 。

- 播放器必须支持 MPRIS:

  - 原生支持：VLC、Audacious、Spotify 等 GUI 播放器。
  - CLI 播放器（如 MPV）：mpv 默认不带 MPRIS 接口，需要安装插件（如 mpv-mpris）才能被 playerctl 识别和控制。
  - 浏览器：Firefox 和 Chrome 内置了 MPRIS 支持，网页播放视频/音乐时，playerctl 同样能直接控制它们。

我的修订配置
==================

.. note::

   虽然通过Pipewire是更为主流的控制声音的解决方案，但是由于依赖较多，而我更希望我的 :ref:`mba11_late_2010` 能够轻装上阵，所以我把上述配置方法中的 ``pactl`` 修改成直接使用内核 ALSA 的 ``alsamixer`` 来控制音量。

:ref:`mba11_late_2010` 顶部的 ``F1~F12`` 功能键在 Linux 下默认发送标准 ``F`` 键信号，按住 ``Fn`` 或配合 ``brightnessctl`` 与 ``wireplumber`` / ``wpctl``（或 ``pamixer`` / ``playerctl`` ）即可轻松绑定控制。

.. literalinclude:: sway_macbook_key_alpine/install
   :caption: 安装 ``brightnessctl`` 等工具

.. note::

   由于我没有安装Pipewire，所以我实际采用底层的Alsa系统控制 ``alsamixer`` 控制音量

注意，安装 ``brightnessctl`` 和 ``alsa-utils`` 会对应安装 ``openrc`` 相关的软件包  ``brightnessctl-openrc`` 和 ``alsa-utils-openrc`` ，这两个OpenRC 服务脚本包是在系统启动（Boot）时自动恢复上一次关机前的屏幕亮度与 ALSA 音量设置，并在系统关机/重启时自动保存当前的设置。建议激活这两个服务:

.. literalinclude:: sway_macbook_key_alpine/openrc
   :caption: 激活亮度和音量控制的OpenRC服务

- 配置 ``~/.config/sway/config`` :

.. literalinclude:: sway_macbook_key_alpine/config
   :caption: 配置sway的config
   :emphasize-lines: 10-13

.. note::

   注意，这里我修订了前面默认模板的控制音量的命令，将默认的 ``pactl`` 替换成 ``alsamixer`` 以便从更底层次的ALSA来控制。

.. _alpine_udev_set_devices_owner:

Alpine Linux udev设置设备属组
=================================

我发现最初按下快捷键没有反应，那么尝试直接执行命令行:

.. literalinclude:: sway_macbook_key_alpine/brightnessctl
   :caption: 执行brightnessctl

显示权限不足:

.. literalinclude:: sway_macbook_key_alpine/brightnessctl_output
   :caption: 执行brightnessctl

那么是什么权限不足呢？我自己的账号 ``admin`` 明明已经位于 ``video`` 组了...

检查:

.. literalinclude:: sway_macbook_key_alpine/ls
   :caption: 检查权限

可以看到实际上文件权限的组是 ``root`` 而不是以为的 ``video`` 组

.. literalinclude:: sway_macbook_key_alpine/ls
   :caption: 检查权限

那么怎么解决？

一种方式是把自己 ``admin`` 加入到 ``root`` 组，但是感觉或许权限放太宽了。所以采用本文的 ``udev`` 动态修改属组:

- (参考,下文有更好的)配置 ``/etc/udev/rules.d/99-backlight.rules`` :

.. literalinclude:: sway_macbook_key_alpine/90-backlight.rules
   :caption: 动态修订属组

.. note::

   在udev规则中， ``%k`` 是一个udev内置的动态占位符(Specifier)，代表"内核分配给该设备的名称(Kernel Name)"

   为什么这么写呢?

   因为不同的硬件设备名称会有细微差别，例如Intel显卡这里的名字是 ``intel_backlight`` ，如果是NVIDIA显卡名字就会变成 ``nv_backlight`` ，而 ACPI通用背光接口则命名是 ``backlight`` 。

   只有采用 ``%k`` 这样的内核动态占位符才能匹配同类型但不同命名的设备，从而保证规则能够精准命中实际的背光控制节点。

- 在现代udev规则中，更推荐直接使用 ``udev`` 内置的属性设置语句 ``GROUP`` 和 ``MODE`` 而不需要显式调用外部命令 ``RUN+=/bin/chmod...`` 和 ``%k`` 占位符:

.. literalinclude:: sway_macbook_key_alpine/99-backlight_better.rules
   :caption: 更符合现代udev规则的 ``/etc/udev/rules.d/99-backlight.rules``

- 重新加载udev规则并出发生效:

.. literalinclude:: sway_macbook_key_alpine/apply
   :caption: 触发udev生效

