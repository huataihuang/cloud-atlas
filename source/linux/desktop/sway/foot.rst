.. _foot:

========================
foot轻量级终端
========================

``foot`` 是一个快速、轻量级以及简单的 :ref:`wayland` 终端模拟器，也是 :ref:`sway` 默认使用的终端。

foot支持CJK，也就是支持中文，但是由于 :ref:`wayland` 对输入法有特定要求，目前 :ref:`fcitx` 在 :ref:`archlinux_sway` 上通过安装 ``sway-im`` 补丁版本实现中文输入显示框。我的实践也验证 :ref:`arch_linux` 使用体验较好(sway环境可以非常方便实现 ``foot`` 中文输入)，而 :ref:`gentoo_sway` 则没有方便的解决方法(至少我还没有成功)。

配置
=======

``foot`` 会加载位于 ``$XDG_CONFIG_HOME/foot/foot.ini``` 配置文件(默认就是 ``$HOME/.config/foot/foot.ini`` )。一般是将模板配置文件从 ``/etc/xdg/foot/foot.ini`` 复制过来进行修改，修订的配置项会覆盖默认配置而达到修改目标。

配色
------

通过修改 ``foot.init`` 的 ``[colors]`` 段落可以定制foot终端配色。

比较方便的方法是使用已经配置好的的配色themes，发行版可以能在 ``/usr/share/foot/themes`` 中提供了配色，就可以在 ``foot.init`` 中添加一段 ``[main]`` 来包含这个配色 theme :

.. literalinclude:: foot/theme
   :caption: 修订 ``~/.config/foot/foot.ini`` 设置配色

我从 `GitHub: catppuccin/foot <https://github.com/catppuccin/foot>`_ 下载配色themes文件存放到 ``~/.config/foot/themes/`` 目录下，采用上述方法设置:

.. literalinclude:: foot/theme_mocha
   :caption: 修订 ``~/.config/foot/foot.ini`` 设置配色 ``catppuccin-mocha.ini``

字体
-----------

默认终端字体是 ``font=monospace:size=8`` ，字体可能偏小，我调整为 ``9``

此外，如果要实现中文字体更美观，可以选择:

.. literalinclude:: foot/font
   :caption: 字体设置

字体名称是通过 ``fc-list`` 过滤找寻

不过，我觉得 ``monospace`` 已经足够美观，特别是对于英文字体显示排版更为好看

终端类型
=============

解决方法一
-------------

如果没有配置 ``foot.ini`` ，那么在默认终端配置实际上就是 ``TERM=foot`` ，但是这个终端类型不被很多终端模拟程序支持，例如远程ssh到其他服务器上使用 :ref:`tmux` 时，就会提示报错:

.. literalinclude:: foot/unsuitable_terminal_err
   :caption: 对于 ``foot`` 终端类型，没有得到 :ref:`tmux` 支持而报错

解决方法就是修订 ``$HOME/.config/foot/foot.ini`` :

.. literalinclude:: foot/foot.ini
   :caption: 配置 ``foot.ini`` 设置终端类型 ``xterm-256color``

这样，再次运行foot就能正确使用 :ref:`tmux`

.. note::

   上述 ``foot.ini`` 配置还设置了终端字体(在 :ref:`mba11_late_2010` 上使用时，默认 ``8`` 号字体太纤细难以辨认，所以稍微增大一些)

.. note::

   ``foot`` 还支持 Server(daemon) 模式，可以节约运行内存消耗并加快启动速度。但是缺点是一旦某个窗口非常繁忙(例如忙于输出)则会导致所有窗口呆住。

   默认 ``foot`` 运行是为每个窗口启动一个foot进程(非daemon模式)

解决方法二
--------------

既然是远程服务器上缺少 ``foot`` 对应的 ``terminfo`` ，那么将本地安装了 ``foot`` 的主机上的对应terminfo复制到远程服务器上也能解决这个问题: 本地安装了 ``foot`` 时有一个 ``/usr/share/terminfo/f/foot`` 终端信息文件，复制为远程服务器的 ``~/.terminfo/f/foot`` 就能够让远程服务器识别 ``foot`` 类型终端。注意目录结构是 ``terminfo/f/`` !

参考
======

- `archlinux wiki: Foot <https://wiki.archlinux.org/title/Foot>`_
- `Things break after I ssh into a remote machine <https://codeberg.org/dnkl/foot/wiki#user-content-things-break-after-i-ssh-into-a-remote-machine>`_
