.. _xmodmap:

=====================
Xmodmap修改键盘映射
=====================

作为技术码农，总是系统自己编码时能够行云流水，所以机械键盘往往是居家旅行、码字编程必备工具。出于颜值，我选择了61键的蓝牙键盘：

.. figure:: ../../_static/linux/arch_linux/keyboard_61.png
   :scale: 75

不过，比较尴尬的是61键机械键盘由于缩略了很多按键，特别是我所购买的富勒61键G610机械键盘存在一个非常不合理的设计：2套键盘布局，默认键盘布局1无法输入 ``/`` 和 ``?`` ，但是布局2则不能输入数字。这对于程序编码非常不友好。

.. note::

   可能在平衡易用性和轻便性，对于编程使用，选择87键机械键盘更为合适。

为了能够解决紧凑型61键机械键盘的输入限制，需要把不常用的键盘按键替换成常用键。例如，将 ``向上键`` 更换成 ``/?`` 。

Xmodmap简介
===============

在每次按下键盘时， Linux 内核都会生成一个 Code。 Code 同 keycodes表 比较，然后决定按下的是什么。

而 Xorg 使用自己的 Keycodes表 来参与这个过程。 每一个 Keycode 属于一个 keysym。 一个 keysym 就像一个 function 被 Keycode 调用执行。 Xmodmap 允许你编辑 keycode-keysym 之间的关系。

Xmodmap映射修改
=================

- 打印当前keymap表::

   xmodmap -pke

这个命令输出的是可阅读的映射配置，例如 ``keycode  57 = n N`` 表明 keycode ``57`` 被映射到小写 ``n`` , 同时大写 ``N``  映射于 ``57 + Shift`` 。

自定义映射表
---------------

- 首先当前映射表输出记录到配置文件::

   xmodmap -pke > ~/.Xmodmap

这个配置文件就是个人使用的定制配置，在这个配置文件中修订，重新登陆X环境都会生效。

- 修订 ``~/.Xmodmap`` 之后，执行以下命令进行刷新测试::

   xmodmap ~/.Xmodmap

- 对于通过 ``startx`` 命令启动Xorg时激活自己定制的映射表，请在 ``~/.xinitrc`` 添加以下内容::

   if [ -f $HOME/.Xmodmap ]; then
       /usr/bin/xmodmap $HOME/.Xmodmap
   fi

我的修订案例(G610键盘)
-------------------------

- 配置 ``~/.Xmodmap`` 修改::

   keycode  64 = Alt_L Meta_L Alt_L Meta_L  # 左Alt键
   keycode 133 = Super_L NoSymbol Super_L  # command键(win键)
   keycode 114 = Right NoSymbol Right   # 向右方向键

- 修改成::

   # 左Alt键和command键互换
   keycode  64 = Super_L NoSymbol Super_L 
   keycode 133 = Alt_L Meta_L Alt_L Meta_L

   # 向右方向键改为`键
   keycode 114 = grave asciitilde grave asciitilde

   # 向上键修改成 /?
   keycode  111 = slash question slash question  # /?

上述配置修改实现的是::

   左Alt键 <=> command键(win键)
   向上键 => /?键
   向右方向键 => `键

macOS的键盘映射
================

我也在macOS系统中使用上述G610机械键盘，同样也存在这个键盘映射的问题。不过，在macOS平台，这个问题解决比较方便，因为有一个开源的 :ref:`macos_keyboard_customize` 工具可以非常灵活定制键盘特性，而且是图形工具，使用非常简便。


参考
=======

- `archlinux官方文档: Xmodmap (简体中文) <https://wiki.archlinux.org/index.php/Xmodmap_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>`_
- `Linux 键盘映射：交换 CapsLock 和 Ctrl <https://harttle.land/2019/08/08/linux-keymap-on-macbook.html>`_
