.. _archlinux_sway:

======================
archlinux Sway图形桌面
======================

我在 :ref:`mobile_cloud_infra` 采用的 :ref:`asahi_linux` 底层是arch linux，为了能够轻量级运行，采用 :ref:`wayland` 核心的 :ref:`sway` 图形桌面。

安装
========

- 建议同时安装::

   pacman -S sway swaylock swayidle swaybg

- 安装 dmenu (本来想安装 wofi 但是发现依赖安装太多软件了)::

   pacman -S dmenu

- ( **由于alacritty不能很好支持中文输入，所以放弃** ) :strike:`安装alacritty作为终端` (参考 :ref:`freebsd_sway` )::

   pacman -S alacritty

- 安装foot(默认sway轻量级终端)::

   pacman -S foot

启动
=======

Sway启动前需要访问硬件设备，例如键盘，鼠标和图形卡，这个硬件信息搜集称为一个 ``seat`` (类似 :ref:`freebsd_sway`)

设置访问方法一: ``polkit`` (推荐)
--------------------------------------

如果系统同时安装了 ``systemd-logind`` (不需要手工安装，默认 :ref:`archlinux_on_mba` 安装过程已经安装) 和 ``polkit`` 就能自动访问 ``seat`` ::

   pacman -S polkit

设置访问方法二: 手工设置加入 ``seat`` 用户组
------------------------------------------------

另一种方式是，如果没有安装 ``polkit`` ，则:

- 安装 ``seatd`` ::

   pacman -S seatd

将自己加入 ``seat`` 用户组，然后激活和启动 ``seatd.service`` ::

   usermod -aG seat admin
   systemctl enable seatd.service
   systemctl start seatd.service

如果没有将用户加入到 ``seat`` 组，则启动sway时候，终端会显示报错:

.. literalinclude:: archlinux_sway/seat_sock_err
   :caption: 用户没有属于 ``seat`` 组，则访问 ``/run/seatd.sock`` 无权限报错

使用
========

启动sway
----------

- 简单启动::

   sway

(使用 ``polkit`` )启动时终端提示:

.. literalinclude:: archlinux_sway/sway_output
   :caption: 安装 ``polkit`` 直接使用 ``sway`` 启动终端输出

``dbus-run-session`` 启动sway(arch linxu似乎不需要)
------------------------------------------------------

.. warning::

   这次我绕了很多弯路， ``dbus-run-session`` 是我之前在 :ref:`gentoo_sway` 中实践所使用的，但是我发现这次在arch linux中套用这个经验没有成功，阅读了arch linux wiki中有关sway的部分，也没有提到需要使用 ``dbus-run-session`` ，所以这段存留，但是 **不要使用** 。

- 如果 :ref:`archlinux_chinese` ，启动时需要增加 ``dbus`` 支持:

.. literalinclude:: ../gentoo_linux/gentoo_sway/start_sway
   :caption: 使用 ``dbus-run-session`` 启动 sway 这样能够正确获得 :ref:`dbus_session_bus`

(使用 ``polkit`` )启动时终端提示:

.. literalinclude:: archlinux_sway/dbus_sway_output
   :caption: 安装 ``polkit`` 使用 ``dbus-run-session`` 启动 sway 输出显示
   :emphasize-lines: 1,2,6-8,10

解决
~~~~~~

- 安装 ``xwayland`` ::

   pacman -S xorg-xwayland

.. note::

   也可以不安装 ``xorg-xwayland`` ，上述报错只是因为arch linux默认的 ``sway`` 配置激活了 ``xwayland`` ，只需要禁止就可以阻止这个报错。也就是修改 ``~/.config/sway/config`` 设置::

      xwayland disable

可以 **消除第1,2行有关xwayland错误** ，此时报错依然有关于dbus报错:

.. literalinclude:: archlinux_sway/dbus_error
   :caption: 补充安装 ``xwayland``  后只解决了xwayland相关报错，但是dbus报错依旧
   :emphasize-lines: 4-6

参考 `process org.freedesktop.systemd1 exited with status 1 #5247 <https://github.com/systemd/systemd/issues/5247>`_ 上述有关 ``org.freedesktop.systemd1`` 报错是由于 ``/usr/share/dbus-1/services/org.freedesktop.systemd1.service`` 有一段代码:

.. literalinclude:: archlinux_sway/org.freedesktop.systemd1.service
   :language: bash
   :caption: ``/usr/share/dbus-1/services/org.freedesktop.systemd1.service`` 执行 ``/bin/false``

为何会出现调用 ``org.freedesktop.systemd1`` 呢，看起来这是一个检测功能。也就是说，当运行环境不满足 ``dbus`` 要求时候，就会走到调用这个注定返回 ``false`` 的子服务。会不会和上面两个没有设置的环境变量有关？

**实践看来和这两个环境变量无关**

参考 `swaywm: XDG_CURRENT_DESKTOP not set <https://bbs.archlinux.org/viewtopic.php?id=289689>`_ ，我在执行 ``dbus-run-session sway`` 之前加上了一个环境变量:

.. literalinclude:: archlinux_sway/xdg_current_desktop
   :caption: 增加 ``XDG_CURRENT_DESKTOP`` 环境变量设置

可以消除环境变量错误，不过 dbus 相关的 ``org.freedesktop.systemd1`` 还是同样报错。

不过，仔细看了报错信息中有 ``dbus-update-activation-environment`` ，在 `arch linux wiki: Sway #Configuration <https://wiki.archlinux.org/title/Sway#Configuration>`_ 有一段说明:

用户配置应该包含  ``include /etc/sway/config.d/*`` 以便引入配置片段。 ``sway`` 软件包提供了 ``50-systemd-user.conf`` 插入文件，该文件将多个环境变量导入 :ref:`systemd` 用户会话和 ``dbus`` 。这对于 ``xdg-desktop-portal-wlr`` 等多个应用程序是必须的。

想到之前在 :ref:`gentoo_sway` 有设置环境变量 ``XDG_RUNTIME_DIR`` 经历，并且需要在 :ref:`gentoo_xdg-desktop-portal` 安装过对应的 ``xdg-desktop-portal-wlr`` ( wayland显示服务器协议 的 wlroots 后端xdg-desktop-portal )，所以参考上次实践也在 arch linux 中安装对应的 ``xdg-desktop-portal`` :

.. literalinclude:: archlinux_sway/xdg-desktop-portal
   :caption: 安装 ``xdg-desktop-portal`` 以及对应的后端 ``xdg-desktop-portal-wlr`` + ``xdg-desktop-portal-gtk``

我发现安装 ``xdg-desktop-portal-gtk`` 也会对应安装themes，所以能够消除上面找不到 ``icon themes`` 的报错(即消除了 ``Warning: no icon themes loaded`` )

.. note::

   暂时没有解决

配置
========

- 将sway系统配置复制过来修改::

   cp /etc/sway/config ~/.config/sway/config

- 修改menu配置::

   #set $term alacritty
   set $term foot

   set $menu dmenu_path | dmenu | xargs swaymsg exec --

还是没有解决dmenu唤起问题

- (放弃)安装chrome和 :ref:`vscode`

chrome很难支持中文输入，仅安装作为备用

vscode使用electron框架，实际上对中文输入支持也很差: 我决定回归到 :ref:`vim` 进行开发

输入设备
==========

支持配置touchpad: ``~/.config/sway/config`` :

.. literalinclude:: archlinux_sway/config_touchpad
   :language: bash
   :caption: sway配置touchpad

.. note::

   - ``dwt`` 表示 ``disable touchpad while typing`` ，这个功能非常有用，激活以后可以避免在sway中输入时候出现聚焦点漂移的问题。不过，我实践下来发现还是需要微调，对于Macbook Pro的touchpad过于灵敏

     - DWT 可能对外接touchpad无效 `DWT not working on Sway with Apple BT Trackpad + wireless keyboard <https://gitlab.freedesktop.org/libinput/libinput/-/issues/524>`_

       - 我参考 `Disable Touchpad while typing not working <https://forum.manjaro.org/t/disable-touchpad-while-typing-not-working/12674>`_ 增加一个选项::

          pointer_accel 0.6 # set mouse sensitivity (between -1 and 1)

   - 如果要彻底关闭touchpad，参考 `sway:  Disabling Touchpad #1277 <https://github.com/swaywm/sway/issues/1277>`_

高分辨率屏幕
=================

对于高分辨率屏幕(HiDPI)，可以在 ``~/.config/sway/config`` 中添加::

   output <name> scale <factor>

这里 ``<name>`` 可以根据 ``swaymsg -t get_outputs`` 中输出显示设备名获得，而这里的 ``<factor>`` 通常可以设置为 ``2`` 。

注意，如果 ``factor`` 设置为非整数倍，则字体显示会有锯齿非常难看。

可以安装图形程序 ``wdisplays`` ( :ref:`archlinux_aur` 安装 )或者终端程序 ``wlr-randr`` ( :ref:`archlinux_aur` 安装 )来修改分辨率，旋转和排列显示器。

``wdispalys`` 可以不用重新加载sway配置即时生效，但是和上文配置sway的 ``output <name> scale <factor>`` 类似，如果配置方法比率不是2或整数，则字体非常难看。

但是，放大比率2我感觉又有点过大了，所以我感觉还是采用调整终端字体以及配置浏览器的页面放大到 150% 较为合适。

锁屏
======

锁屏使用 ``swaylock`` ，并且可以参考 `Script output over a random image in swaylock <https://forum.archlabslinux.com/t/script-output-over-a-random-image-in-swaylock/5944>`_ 切换锁屏图片 (尚未实践)

``swaylock`` 结合 ``swaylock-effects`` 可以输出一些信息，如时间::

   swaylock --clock --indicator --screenshots --effect-scale 0.4 --effect-vignette 0.2:0.5 --effect-blur 4x2 --datestr "%a %e.%m.%Y" --timestr "%k:%M"
   
参考
======

- `Complete the Sway experience: Swaybg, Swayidle, Swaylock, Alacritty, Waybar, Brigtnessctl #1296 <https://github.com/clearlinux/distribution/issues/1296>`_ 非常好的参考，引述了多个必要组件
- `Lock screen config in sway <https://code.krister.ee/lock-screen-in-sway/>`_
