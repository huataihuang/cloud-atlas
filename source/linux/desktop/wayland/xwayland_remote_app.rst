.. _xwayland_remote_app:

===========================
Xwayland远程运行应用
===========================

我在 :ref:`waypipe_pi` 实践中遇到一个困难: :ref:`mba11_late_2010` 显卡硬件不支持Vulkan，导致无法使用原生的Waypipe: Waypipe 的 Rust 依赖项在当前 Alpine/Sway 环境下依然强行硬编码检查 Vulkan。

为了解决这个硬件限制问题，我改为将Wayland回退支持Xwayland，这样在处理 Chromium 这类重度 Web 渲染时，SSH X11 转发配合树莓派 5 强悍的 A76 CPU 软解，体验可能比死磕 Waypipe 的 DMABUF Bug 更顺畅。

- 在树莓派 5 上安装 Xwayland 与 Chromium 的 X11 依赖:

.. literalinclude:: waypipe_pi/install_xwayland
   :caption: 在服务器安装 Xwayland 与 Chromium 的 X11 依赖

- 在 MacBook Air 上直接通过 ``ssh -X`` 启动

.. literalinclude:: waypipe_pi/ssh_x
   :caption: 通过Xwayland兼容模式运行

出现报错

.. literalinclude:: waypipe_pi/ssh_x_error
   :caption: 通过Xwayland兼容模式运行报错

这个报错需要检查服务器，确保 ``/etc/ssh/sshd_config`` 允许X11 转发:

.. literalinclude:: waypipe_pi/sshd_config
   :caption: 服务器端sshd必须允许X11转发

并且需要检查在客户端( :ref:`mba11_late_2010` )上的 :ref:`sway` 配置 ``~/.config/sway/config`` 确保允许 ``xwayland enable`` ，这样进入sway桌面，执行:

.. literalinclude:: waypipe_pi/display
   :caption: 检查DISPLAY

输出显式:

.. literalinclude:: waypipe_pi/display_output
   :caption: 检查DISPLAY输出信息

这个输出信息并没有显式出X DISPLAY，这说明在客户端( :ref:`mba11_late_2010` )没有安装Xwayland相关的软件包，需要补充安装:

.. literalinclude:: waypipe_pi/install_xwayland_client
   :caption: 在客户端也需要安装Xwayland

然后重新启动一次sway,再次检查

.. literalinclude:: waypipe_pi/display
   :caption: 检查DISPLAY

正确的输出信息应该是

.. literalinclude:: waypipe_pi/display_output_ok
   :caption: 检查DISPLAY输出信息,正确的输出信息有两行
   :emphasize-lines: 2

果然，现在执行就正常了:

.. literalinclude:: waypipe_pi/ssh_x
   :caption: 通过Xwayland兼容模式运行

终于看到chrome的窗口了!!!

X11 / Xwayland 键盘映射表
---------------------------

遇到一个奇怪的事情似乎客户端和服务器的键盘规格不一致导致的: 我输入url以后打回车，但是显示的却是字幕 j ，回车没有用处

在 Linux 下，按键按下时硬件输出的是 **Scancode（扫描码）** ，然后通过 **XKB（X Keyboard Extension）映射表** 将其转换为具体的 **Keycode / Keysym（字符）** 。

在 MacBook Air 上通过 ssh -X 将远程树莓派的 X11 窗口（Chromium）拉回到本地的 Xwayland 渲染时:

- 本地 Sway 运行在现代 Wayland 协议下，使用 Linux Input 规范
- 树莓派的 Chromium 运行在 X11 协议下: ``ssh -X`` 在建立隧道时，把树莓派端的 X11 默认键盘映射（通常是标准的 104 键 PC 布局或默认规则）直接挂到了 MacBook Air 的 Xwayland 客户端上，导致按键码对不齐。

解决方法: 启动 Chromium 前，强制将远程 X11 会话的键盘映射同步重置为标准的 104 键（或 Mac 键盘）布局，或者强制 Chromium 走原生的 Wayland / XKB 传递。

- 在树莓派上安装 ``x11-xserver-utils`` (包含 ``setxkbmap`` )

.. literalinclude:: waypipe_pi/install_setxkbmap
   :caption: 在树莓派上安装 ``setxkbmap``

- 启动时先重置键盘映射，再启动 Chromium:

.. literalinclude:: waypipe_pi/ssh_x_setxkbmap
   :caption: 通过Xwayland兼容模式运行，启动时先重置键盘映射

这里又有一个报错:

.. literalinclude:: waypipe_pi/ssh_x_setxkbmap_error
   :caption: 通过Xwayland兼容模式运行，启动时先重置键盘映射，报错

因为 ``ssh -X`` （受限的 X11 转发模式）出于安全考虑，默认屏蔽了 X11 的 XKB 扩展功能。当 ``setxkbmap`` 尝试向这个受限的 X11 伪 Display 写入键盘映射时，X Server 拒绝了该请求，因此触发报错。

只要改用 -Y（Trusted X11 forwarding，信任模式），SSH 就会完整放开 XKB 扩展在内的所有 X11 协议支持:

.. literalinclude:: waypipe_pi/ssh_y_setxkbmap
   :caption: 通过Xwayland兼容模式运行，启动时先重置键盘映射，信任模式 ``-Y``

现在验证就看到了输入完整，回车键也能正常工作

- 适配Mac键盘: 由于我现在使用的 :ref:`mba11_late_2010` 采用的是Mac键盘，所以上述命令还可以再改进 ``setxbmap`` 键盘映射

.. literalinclude:: waypipe_pi/ssh_y_setxkbmap_mac
   :caption: 通过Xwayland兼容模式运行，启动时先重置键盘映射，信任模式 ``-Y`` 键盘设置为Mac

中文显示和输入
---------------

- 在树莓派服务器端需要安装中文字体才能确保chrome中正常 :ref:`linux_chinese_view` :

.. literalinclude:: ../chinese/linux_chinese_view/apt_install_fonts-wqy
   :caption: 安装中文字体

- 客户端 :ref:`mba11_late_2010` 上需要正确配置 :ref:`alpine_sway_mba11_late_2010` :

.. literalinclude:: ../chinese/fcitx/environment
   :language: bash
   :caption: 启用fcitx5环境变量配置 /etc/environment
   :emphasize-lines: 1-3

- 在 MacBook Air 终端上运行 SSH 命令时，显式将 ``XMODIFIERS`` 传递给树莓派端的 Chromium（或者使用 ``-E`` 选项保留环境变量）

.. literalinclude:: waypipe_pi/ssh_y_setxkbmap_mac_fcitx
   :caption: 通过Xwayland兼容模式运行，启动时先重置键盘映射，信任模式 ``-Y`` 键盘设置为Mac，并传递 ``XMODIFIERS``

.. note::

   有一点点遗憾，现在确实能够输入中文，但是输入速度不能太快，太快的话部分输入字母会  没有被本地fcitx捕获而直接将英文字母传输给了远程的chromium应用，导致中文中夹杂着英文字母(拼音字母)

.. warning::

   上述遗憾一直存在，我尝试了gemini提供的几个建议都解决不了快速输入导致的部分拼音字母直接传递给远程应用，导致中文和英文混杂。

   **最终还是只能忍受中文输入慢一些**

   本文后面的一些尝试记录不用再看了

- ( ``验证无效`` )gemini建议将老旧且低效的 X11 同步协议( ``GTK_IM_MODULE=xim`` )改为 ``dbus / fcitx`` 可以让 Fcitx5 走异步事件通道: 由于 ``ssh -Y`` 会默认转发 DBus 信号（或者共享 Session DBus），直接使用 fcitx 作为模块驱动可以极大地降低网络确认延迟

.. literalinclude:: waypipe_pi/ssh_y_setxkbmap_mac_fcitx_dbus
   :caption: 通过Xwayland兼容模式运行，启动时先重置键盘映射，信任模式 ``-Y`` 键盘设置为Mac，并 **使用dbus** 直接用 fcitx 作为模块驱动

但是这个方法实际验证反而导致无法呼出输入法，所以失败了

- ( ``验证无效`` )gemini建议 "降级 X11 输入层为异步 xim 延迟修复" : 如果不得不使用 xim，可通过在启动命令中为 Chromium 增加 X11 异步标志，禁止 X11 在等待 XIM 响应时丢弃包

.. literalinclude:: waypipe_pi/ssh_y_setxkbmap_mac_fcitx_xim
   :caption: 通过Xwayland兼容模式运行，启动时先重置键盘映射，信任模式 ``-Y`` 键盘设置为Mac，并传递 ``XMODIFIERS`` + chromium增加X11异步标志

- ( ``验证无效`` )gemini还有一个建议是 **优化 Fcitx5 的按键转发行为，防止它在处理 X11 事件时向远端透传未处理完的按键** :

  - Fcitx5 配置界面（或修改 ``~/.config/fcitx5/config`` ）
  - 在 全球配置 (Global Options) -> 高级 (Advanced) 中:

    - 将 Forward Unhandled Key (转发未处理按键) 设为禁用或延时处理
    - 开启 Share Input State (共享输入状态)

按照gemini提供的配置，尝试修订 ``~/.config/fcitx/config`` :

.. literalinclude:: waypipe_pi/fcitx_config
   :caption: 修改fcitx配置，优化Fcitx5 本地“前向提交 / 异步处理”

但是很不幸，这个方案也没有效果

进一步改进
============

在使用上述Xwayland解决远程访问应用之后，实际使用可以看到较为流畅的体验，基本和本地使用应用非常相近，除了色彩压缩以后比较单薄。

不过，在访问Youtube等网站就会发现，视频播放是没有声音，所以需要进一步改进 :ref:`xwayland_remote_audio`

参考
======

- gemini
