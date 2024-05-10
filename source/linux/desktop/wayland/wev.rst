.. _wev:

==============
wev
==============

在 :ref:`install_gentoo_on_mbp` 之后，我使用了 :ref:`sway` 作为自己的轻量级桌面。 ``sway`` 采用 :ref:`wayland` 作为图形系统，和以往的X Window有很大差异。并且 :ref:`sway` 主要结合快捷键使用，我希望能够充分利用 :ref:`mba13_early_2014` / :ref:`mbp15_late_2013` 的专用按键，例如音量调节键，屏幕光亮调节键。

在X Window环境下，有一个 ``xev`` 工具可以用来捕获键盘和鼠标事件，转换成终端输出的字符串，这样我们就能知道每次按键所代表的事件，就能够结合到桌面快捷键映射工具 ``xbindkey`` (配置文件为 ``~/.xbindkeyrc`` )实现任何基于X Window的桌面管理器的快捷键动作。

同样，在 :ref:`wayland` 环境也有一个类似的小工具 ``wev`` ，是由开源项目 `git.sr.ht: ~sircmpwn/wev <https://git.sr.ht/~sircmpwn/wev>`_ 提供的:

安装
======

- 直接源代码编译，依赖:

.. literalinclude:: wev/dependencies
   :caption: ``wev`` 运行和编译依赖

- 编译安装:

.. literalinclude:: wev/build
   :caption: 编译安装 ``wev``

使用
=======

直接在图形桌面的终端中运行 ``wev`` ，然后在弹出的窗口中移动鼠标和按下键盘按键，就会看到终端输出中事件信息，也就能对应配置 :ref:`sway` 的 ``bindsym`` 配置

参考
======

- `archlinux wiki: Keyboard input <https://wiki.archlinux.org/title/Keyboard_input>`_
- `Wave Hello To WEV - Similar To X.Org's Xev For Event Viewing On Wayland <https://www.phoronix.com/news/Wayland-WEV-Events>`_
