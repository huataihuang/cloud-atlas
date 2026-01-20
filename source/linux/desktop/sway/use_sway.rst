.. _use_sway:

==========================
使用sway
==========================

我最初只会简单的sway快捷键，有些窗口布局我甚至是使用鼠标来拖放窗口完成的。但是，当我开始使用 :ref:`thinkpad_x220` 这样古老的笔记本(对 :ref:`freebsd` 支持极好)，12.5英寸分辨率1366x768的经典小屏机器，迫使我研究 :ref:`sway_config` 来实现极致的紧凑布局。

这也带来一个问题，当所有的窗口标题栏消失以后，已经无法使用鼠标拖放完成窗口布局，不得不完全以来键盘操作布局。这迫使我重新回来学习基本的sway快捷键。

"左一右二"布局
================

在Sway(i3-like)的平铺逻辑中，默认的平铺方式是"水平平铺"。要实现"左一右二"(右边两个窗口上下排列)，关键是使用"切换切分方向(Split Direction)"快捷键:

- ``Mod + h`` : 水平切分(Horizontal)
- ``Mod + v`` : 垂直切分(Vertical)

"左一右二" 在布局时候，第2个窗口布局好以后，在启动第3个窗口前，按以下 ``Mod + v`` 见默认水平切分改为垂直切分，那么启动的第3个窗口就会在第2个窗口下方，形成 "左一右二"(右边两个窗口上下排列)

预设切分方向快捷键
============================

在Sway中，虽然也能通过拖拽来调整布局，但是这不是核心能力，真正的核心是预设切分方向快捷键:

.. csv-table:: sway预设切分方向快捷键
   :file: run_sway/shutcut.csv
   :widths: 25,25,50
   :header-rows: 1

自动化布局脚本
=================

可以使用 ``swaymsg`` 写一个简单的Shell脚本:

.. literalinclude:: use_sway/firefox_foot_array
   :language: bash
   :caption: 自动布局firefox和foot的脚本

这个脚本命令可以组合成一个 ``$mod+shift+z`` 组合键来一次性自动布局好

.. literalinclude:: use_sway/firefox_foot_array_config
   :caption: 配置一键布局

不过，实践发现脚本布局是失败的: 当系统中已经启动过 firefox 和 foot ，再启动布局，总是一晃而过无法正确排版。

Google Gemini 提供了一个脚本，确保脚本只针对新启动的那个窗口进行操作：通过临时标记（Mark）来精准定位新窗口。

.. literalinclude:: use_sway/layout.sh
   :language: bash
   :caption: 布局脚本

.. warning::

   以上脚本验证不成功，暂时没有时间折腾，先记录待后续排查
