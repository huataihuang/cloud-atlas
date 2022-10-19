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

- (由于alacritty不能很好支持中文输入，所以放弃):strike:`安装alacritty作为终端` (参考 :ref:`freebsd_sway` )::

   pacman -S alacritty

- 安装foot(默认sway轻量级终端)::

   pacman -S foot

启动
=======

Sway启动前需要访问硬件设备，例如键盘，鼠标和图形卡，这个硬件信息搜集称为一个 ``seat`` (类似 :ref:`freebsd_sway`)，所以需要安装::

   pacman -S seatd

如果系统同时安装了 ``polkit`` ，那么 Sway 可以自动访问seat。另一种方式是，如果没有安装 ``polkit`` ，则将自己加入 ``seat`` 用户组，然后激活和启动 ``seatd.service`` (我采用这种方法)::

   systemctl enable seatd.service
   systemctl start seatd.service

- 启动::

   sway

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
