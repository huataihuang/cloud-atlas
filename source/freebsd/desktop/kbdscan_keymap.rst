.. _kbdscan_keymap:

===============================================
按键代码(kbdscan)和按键映射(keyboard mapping)
===============================================

我在 :ref:`freebsd_on_thinkpad_x220` 遇到一个非常奇怪的问题，无法使用 ``Windows`` 按键。因为我使用 :ref:`freebsd_sway` ， ``Windows`` 健失效也就导致无法使用快捷键。但是，为何会出现这个情况呢？

按键扫描获取按键代码
======================

首先我想要确认键盘物理工作正常与否: 因为为了更换 :ref:`thinkpad_x220` 风扇，整个笔记本被整个拆卸过。虽然可能性不大

``kdbscan`` 是一个非常好的终端工具(无需X)，在FreeBSD中首先安装:

.. literalinclude:: kbdscan_keymap/install
   :caption: 安装kdbscan

然后在终端中直接运行 ``kbsscan`` 命令，此时终端中按下任何一个键会自动打印按键对应的编码

.. note::

   ``xev`` 程序也能够获得按键代码，不过是在X环境中使用

从 `Modifier keys <https://wincent.dev/wiki/Modifier_keys>`_ 提供了特殊按键代码，对比上述 ``kdbscan`` 获得的按键代码，整理如下

.. csv-table:: ThinkPad X220 key code对比
   :file: kbdscan_keymap/keycode.csv
   :widths: 30, 30, 40
   :header-rows: 1

按键映射
===========

FreeBSD使用了 ``/usr/share/vt/keymaps`` 目录下的键盘配置文件，按照你安装过程选择，默认可能是 ``us.kbd`` 

.. note::

   我很困扰如何修改这个配置

   暂时有点倦怠，暂时不想折腾 :ref:`freebsd_sway` 和 :ref:`freebsd_hikari` ，我想把时间集中到开发和 :ref:`machine_learning` ，所以我回退到 :ref:`freebsd_xfce4`

参考
======

- `Tip: Thinkpad PT_BR keyboard (BR ABNT2) problems with the slash and question mark "/" and "?" in the shell. <https://forums.freebsd.org/threads/tip-thinkpad-pt_br-keyboard-br-abnt2-problems-with-the-slash-and-question-mark-and-in-the-shell.97297>`_
- `Modifier keys <https://wincent.dev/wiki/Modifier_keys>`_ 提供了特殊按键代码，例如在Linux中 ``Super_L`` 的keycode是 133
