.. _xwayland_remote_audio:

=============================
Xwayland远程音频播放
=============================

.. warning::

   太奔溃了，我花了一天时间还是没有搞定，似乎就差一点点...

   但是太累了，实在不想花时间解决这种非常边角料的桌面问题，放弃了...

在 :ref:`xwayland_remote_app` 实践时，采用了如下远程运行chrome的方法:

.. literalinclude:: waypipe_pi/ssh_y_setxkbmap_mac_fcitx
   :caption: 通过Xwayland兼容模式运行，启动时先重置键盘映射，信任模式 ``-Y`` 并传递 ``XMODIFIERS`` 以支持中文输入

但是发现无法播放远程主机上的音频，例如访问Youtube是完全无声的。

原因是: ``ssh -Y`` 和 ``X11`` 协议本身只负责传递"图形界面与输入事件"，完全不包含任何音频传输协议。

使用 PulseAudio / PipeWire 网络音频转发
===========================================

:ref:`mba11_late_2010` 运行的是 :ref:`alpine_linux` 和 :ref:`sway` ，而 :ref:`pi_5` 运行的是 :ref:`raspberry_pi_os` ，默认使用的是 ref:`pulseaudio` 或 :ref:`pipewire` （兼容 PulseAudio 协议）来管理声音的。

通过 :ref:`ssh` 建立一条轻量级音频隧道，可以将 :ref:`pi_5` 的声音直接重定向到 :ref:`mba11_late_2010` 。以下分三种音频解决方案( :ref:pipewire` , :ref:`pulseaudio` 和 :ref:`alsa` )对应的音频重定向。

PipeWire网络音频转发
------------------------

.. note::

   对于仅运行远程的应用，将远程应用的音频转发给本地系统发声，不需要安装配置 ``xdg-desktop-portal`` (详见 :ref:`alpine_sway` )

相比于传统的PulseAudio， ``PipeWire`` 采用了C语言编写的无锁(Lock-free)图架构，CPU占用率和内存开销大幅降低(在Alpine上运行占用通常不到10MB内存)，甚至接近纯 :ref:`alsa` 的轻量级表现；同时它又原生支持 :ref:`pulseaudio` 协议，彻底解决了纯ALSA模式下网络传输需要手写PCM管道、缺乏网络自动混音与音量控制的痛点。

alpine linux安装PipeWire
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. literalinclude:: xwayland_remote_audio/install_pipewire
   :caption: 安装PipeWire套件

虽然gemini提示可以使用OpenRC User Services方式配置启动，但是我尝试没有成功，似乎这种方式依赖于PAM/elogind完全接管OpenRC用户会话，但是我的简化 :ref:`sway` 没有使用elogind，我也没有进一步尝试，而是改为采用最简单 ``~/.config/sway/config`` 添加:

.. literalinclude:: xwayland_remote_audio/config
   :caption: 通过sway的 ``~/.config/sway/config`` 启动用户级的PipeWire进程

重新进入sway环境后用以下命令验证:

.. literalinclude:: xwayland_remote_audio/pactl
   :caption: 检查PipeWire是否正确运行

输出显式:

.. literalinclude:: xwayland_remote_audio/pactl_output
   :caption: 可以看到 ``Server Name`` 显示为 ``PulseAudio (on PipeWire ...)``
   :emphasize-lines: 9

树莓派安装PipeWire
~~~~~~~~~~~~~~~~~~~~

对于我采用最小化(Lite)安装的 :ref:`pi_5` ，采用如下命令安装PipeWire, PulseAudio兼容层以及Session管理器:

- 在 :ref:`raspberry_pi_os` ( :ref:`debian` )上安装PipeWire

.. literalinclude:: xwayland_remote_audio/apt_pipewire
   :caption: 在树莓派中安装PipeWire

说明:

  - ``pipewire`` ：PipeWire 核心服务。
  - ``pipewire-pulse`` ：PulseAudio 协议兼容层（Chromium 会通过这个组件把声音发出来）。
  - ``wireplumber`` ：PipeWire 的媒体会话与设备管理器。

- 启动PipeWire用户级服务

.. literalinclude:: xwayland_remote_audio/systemctl
   :caption: 启动PipeWire用户级服务

此时会看到 :ref:`systemd` 在用户目录下创建了服务的链接并启动，这非常类似 :ref:`systemd` 系统级服务，区别是建立在用户目录下，采用用户权限运行:

.. literalinclude:: xwayland_remote_audio/systemctl_output
   :caption: 启动PipeWire用户级服务的输出信息

- 验证启动状态:

.. literalinclude:: xwayland_remote_audio/status
   :caption: 检查服务状态

输入类似如下，其中 ``active (running)`` 表明树莓派端的音频服务已经启动

.. literalinclude:: xwayland_remote_audio/status_output
   :caption: 检查服务状态显式输出

运行Chromium(异常排查)
=========================

一切就绪，现在在 :ref:`xwayland_remote_app` 基础上改进远程运行chromium命令:

.. literalinclude:: xwayland_remote_audio/remote_chromium_audio
   :caption: 增加了SSH隧道( ``-R 4713`` )将音频回传到本地PipeWire播放
   :emphasize-lines: 2,4

此时我发现还是没有声音，gemini提示本地的 ``PipeWire`` 开启了安全拦截，就会静音

- 在本地 :ref:`alpine_linux` 上执行以下命令，强制开启TCP监听允许:

.. literalinclude:: xwayland_remote_audio/pactl_acl
   :caption: 通过 ``pactl`` 命令允许TCP监听

此时通过 ``ss`` 检查端口

.. literalinclude:: xwayland_remote_audio/ss
   :caption: 检查端口

会发现原本空白的输出现在出现了有 ``pipewire-pulse`` 进程在监听 ``127.0.0.1:4713`` :

.. literalinclude:: xwayland_remote_audio/ss_output
   :caption: 检查端口可以看到 ``pipewire-pulse`` 进程监听

- 在本地 :ref:`mba11_late_2010` 的 :ref:`alpine_linux` 上安装 PulseAudio / PipeWire 图形化音量控制器:

.. literalinclude:: xwayland_remote_audio/install_pavucontrol
   :caption: 安装pavucontrol

.. note::

   这个 ``pavucontrol`` 是一个GTK4程序，所以会依赖安装不少软件。为了轻量化，可以改为安装 ````pulsemixer`` ，一个基于终端采用Python编写的程序，没有任何GTK/X11依赖:

   .. literalinclude:: xwayland_remote_audio/install_pulsemixer
      :caption: 安装 pulsemixer

   使用时用方向键或 ``h/j/k/l`` 选择设备，调整音量、静音( ``m`` 键)

   观察应用的音量流，也是切换到 ``playback`` 选项卡

运行 ``pavucontrol`` 或 ``pulsemixer`` ，切换到 ``Playback`` 面板观察，如果YouTube在播放，此时应该观察到应用 ``chromium`` 在播放

- 为了检查整个流程，也就是SSH连接树莓派之后能否正常将远程音频在本地播放，执行以下命令:

.. literalinclude:: xwayland_remote_audio/test
   :caption: 测试声音播放

此时我听到了沙沙声(白噪音)，这说明PipeWire网络管道完全正常，问题在chromium内部

- 由于 :ref:`pi_5` 是最小化系统，所以需要补充安装PulseAudio/PipeWire 通信的底层 Sound API 动态链接库: 

.. literalinclude:: xwayland_remote_audio/apt_install_pulseaudio-utils
   :caption: 安装 PulseAudio/PipeWire 通信的底层 Sound API 动态链接库

但是发现播放YouTube还是没有声音，所以怀疑是chromium默认可能直接连接了ALSA硬件驱动，而没有通过 :ref:`pulseaudio` ，所以修订运行命令，添加 ``--alsa-output-device=pulse`` 参数:

.. literalinclude:: xwayland_remote_audio/remote_chromium_audio_pulse
   :caption: 指定使用pulse
   :emphasize-lines: 8

尝试再增加 ``--disable-audio-sandobx`` 避免沙箱中无法使用TCP端口转发:

.. literalinclude:: xwayland_remote_audio/remote_chromium_audio_pulse_without_sandbox
   :caption: 关闭audio沙箱
   :emphasize-lines: 9

奔溃，还是无声

gemini 提示检查 chromium 的 ``chrome://media-internals`` ，果然发现一个异常的现象 ：

- Output Streams 的表格中 ``device_id`` 是空白的
- ``device_type`` 显示是 ``fake``

``device_type: "fake"`` 意味着 Chromium 根本没有把声音输出到任何真正的声卡或 PulseAudio 接口上，而是直接把音频路由到了内核内置的“虚拟哑设备 (Fake/Dummy Audio Sink)”里。

Chromium 在 Linux 上（尤其是在没有本地物理声卡硬件的树莓派 Lite/无头服务器环境）会自动检测底层音频硬件。如果它发现本地没有可用声卡，就会触发回退机制（Fallback），强制将所有音频流定向到 fake 设备。

只要进入了 fake 状态，Chromium 就会完全忽略 Shell 中传入的 PULSE_SERVER 环境变量以及 ``libpulse.so`` 。

尝试以下命令，针对无头服务器 / 跨端 X11 转发 / 无本地物理声卡等特殊 Linux 场景下，用来覆盖 Chromium 默认策略:

.. literalinclude:: xwayland_remote_audio/remote_chromium_audio_pulse_without_sandbox_default
   :caption: 增加 ``--alsa-output-device=default`` 强制chromium使用PipeWire
   :emphasize-lines: 8

但是此时检查验证 ``device_type: "fake"`` 依然没有变化。这说明chromium依然检测到没有物理声卡而强行使用 fake。

尝试在树莓派内核建在一个ALSA虚拟声卡 ``snd-dummy`` :

.. literalinclude:: xwayland_remote_audio/snd-dummy
   :caption: 虚拟声卡

完成后检查 ``lsmod | grep snd_dummy`` (注意是下划线)就会看到加载了模块 ``snd_dummy`` 然后运行检查命令 ``aplay -l`` :

.. literalinclude:: xwayland_remote_audio/aplay
   :caption: ``aplay -l`` 检查声音设备
   :emphasize-lines: 2,5,8

唉，搞错了，原来chromium是检测到声卡的:

- 我使用的设备是 :ref:`pi_5` ，有2个HDMI输出口作为音频输出设备 **SoC (BCM2712) 默认将 card 0: vc4hdmi0 和 card 1: vc4hdmi1 注册为了前两个 ALSA 硬件输出设备。**
- Chromium 启动时，默认调用 ALSA 探测 **Hardware Card 0 (hw:0,0)**
- ``card 0: vc4hdmi0`` (HDMI 输出)，但由于没有连接支持HDMI音频的显示器(其实我根本没有接显示)，该 ALSA 接口处于 ``Disconnected / Unplugged`` 逻辑状态
- Chromium 检测到 Card 0 不可用且没有配置默认重定向，为了防止播放崩溃，自动触发保护机制，回退到了 ``fake`` 哑设备

解决方案: 将 ALSA 的默认声卡强行指向 ``Dummy`` 或 ``pulse``

- 需要修改树莓派上的 ALSA 全局/用户配置文件，跳过 Card 0 和 Card 1（HDMI），把 ALSA 的 default 绑定到 Dummy 虚拟声卡或者直接路由给 pulse:

.. literalinclude:: xwayland_remote_audio/asoundrc
   :caption: 重新配置 ``~/.asoundrc`` 强制默认走pulse的4713端口

- 由于 Chromium 之前记住了 Card 0 (HDMI) 不可用从而回退到了 fake，需要重置它的 Media 缓存

.. literalinclude:: xwayland_remote_audio/clean
   :caption: 清理Media缓存

- 因为已经在 ``~/.asoundrc`` 中把 ``default`` 和 ``pulse`` 都映射到了 ``127.0.0.1:4713`` ，所以现在启动命令可以简化，只需要 ``--alsa-output-device=default`` 就可以了:

.. literalinclude:: xwayland_remote_audio/remote_chromium_audio_pulse_without_sandbox_default_simple
   :caption: 简化启动命令

.. warning::

   太奔溃了，上述方法还是无法让chromium认为自己在和PulaseAudio交互。

   我改变方法，采用 "树莓派本地用 paprefs / PulseAudio 把本地声卡与远程 4713 建立硬绑定" ，见下文

全局 PulseAudio/PipeWire TCP 桥接
===================================

上面实践已经验证树莓派上使用 aplay 可以正常把白噪音推到 MacBook Air，说明 PulseAudio TCP 通道本身是完全通畅的，问题在于 Chromium 进程找不到本地挂载的 Pulse 抽象，或者与 TCP 端口的握手被 Chromium 内核给拦截掉了。

**Chromium 只有在感知到系统里运行着一个标准的 PulseAudio 守护进程时，才会把 device_type 从 fake 切换为真正的音频管道。**

- 在 树莓派 5 上执行以下命令，在本地 PulseAudio 配置中添加网络重定向模块:

.. literalinclude:: xwayland_remote_audio/default.pa
   :caption: 配置PulseAudio 客户端配置指向 4713

不过这两条命令都报错 ``Connection failure: Connection terminated`` 原因是SSH无头模式下，之前执行的 ``systemctl --user enable --now pipewire pipewire-pulse`` 在会话断开以后被系统挂起了。

不可行方法
------------

:strike:`另一种方式(更为简单直观)放弃树莓派本地 PipeWire` ，直接用 ``apulse`` **该方法我验证不行会导致YouTube视频无法播放** :

不想在树莓派 Lite 上维护后台 PipeWire 进程，完全可以绕过 pactl 命令，直接使用 ``apulse`` : apulse 不需要树莓派跑任何 PulseAudio/PipeWire 守护进程，它只是一层纯 C 语言编写的 .so 动态库拦截器，能在启动 Chromium 的瞬间直接把 Pulse 调用抓包转给 ALSA。

.. literalinclude:: xwayland_remote_audio/remote_chromium_audio_pulse_without_sandbox_apulse
   :caption: 简化启动命令，但是通过 apulse 启动 chromium

这样 Chromium 会认为系统里有 PulseAudio，而 apulse 会读取配置好的 ``~/.asoundrc`` ，直接通过 ``SSH -R 4713`` 隧道吐回 MacBook Air。

可行方法
---------

让PipeWire用户服务在后台持续运行:

.. literalinclude:: xwayland_remote_audio/enable-linger
   :caption: 配置用户在未登录桌面时也能常驻运行 ``systemd --user`` 服务

然后重新运行:

.. literalinclude:: xwayland_remote_audio/pactl_load-module
   :caption: 重新加载模块

创建/覆盖 ``~/.config/pulse/default.pa``

.. literalinclude:: xwayland_remote_audio/default.pa
   :caption: 配置PulseAudio 客户端配置指向 4713

这里需要重启本地音频服务:

.. literalinclude:: xwayland_remote_audio/restart_pipewire-pulse
   :caption: 重启音频服务

参考
======

- gemini
