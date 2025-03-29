.. _kmscon:

===============================
kmscon - 基于linux内核kms终端
===============================

`kmscon终端 <https://www.freedesktop.org/wiki/Software/kmscon/>`_ 是基于linux :ref:`kms` 的精简终端模拟器，尝试在用户空间控制台替换位于内核的VT实现。 ``kmscon`` 不依赖任何图形服务器(例如X.org)，但是提供一个底层控制层，也可以无依赖使用。 ``kmscon`` 提供了系统控制台的国际化支持，通过默认字体引擎 ``pango`` 来渲染CJK字符。

不过，kmscon于2015年3月停止开发，后继还有一个 ``systemd-consoled`` 也于2015年7月停止开发 - `What ever happened to systemd-consoled, and the effort to replace config_vt? <https://www.reddit.com/r/linux/comments/8yox3f/what_ever_happened_to_systemdconsoled_and_the/>`_

目前字符终端项目开发似乎不再进行，可能开源关注点在于图形界面，我尚未找到合适的在 :ref:`raspberry_pi_os` 上使用kmscon的方法，似乎只在 :ref:`arch_linux` 发行版提供了 ``kmscon`` 。

kmscon功能
============

kmscon支持unicode，并且只硬依赖 ``udev`` ，可选编译使用 Mesa 来硬件加速控制台，并使用 ``pango`` 库来提高字符渲染。

使用XKB输入允许kmscon能够使用所有为X.Org Server和Wayland compositors开发是的输入键盘布局，也使它有可能使用同时用于图形环境和字符终端的键盘布局。(如中文输入)

从文档来看，和 :ref:`fbterm` 类似， ``kmscon`` 能够很好实现字符终端的CJK输入。

.. note::

   对于Unix/Linux古早用户来说，能够完全在字符终端完成所有工作，是一种非常古老而怀旧的体验。也许我会做这样的事...

相关开源项目
==============

kmscon还发展出两个项目:

- `wlterm <https://www.freedesktop.org/wiki/Software/kmscon/wlterm/>`_ 原生Wayland termianl用于测试Wayland API`
- `libtsm <https://www.freedesktop.org/wiki/Software/libtsm/>`_ 尝试兼容所有现存模拟终端，如xterm, gnome-terminal, konsole ...

参考
=======

- `Arch Linux KMSCON <https://wiki.archlinux.org/title/KMSCON>`_
- `wikipedia - kmscon <https://en.wikipedia.org/wiki/Kmscon>`_
