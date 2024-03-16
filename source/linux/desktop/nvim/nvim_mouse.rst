.. _nvim_mouse:

=====================
Neovim和鼠标
=====================

我刚开始使用neovim的时候，遇到一个烦恼: 默认鼠标功能是随时激活的，在进入编辑时，稍微触碰一下触摸板就会导致光标飘移到其他位置，很容易导致输入到错误的位置。

neovim提供了一个 ``mouse`` 选项，可以配置在哪些模式下启用鼠标:

- ``n`` : Normal mode
- ``v`` : Visul mode
- ``i`` : Insert mode
- ``c`` : Command-line mode
- ``h`` : 当编辑一个帮助文件时所有之前的模式
- ``a`` : 所有之前模式
- ``r`` : 针对 ``hit-enter`` 和 ``more-prompt``

也就是说，我可以设置只在 ``c`` 模式下启用鼠标:

.. literalinclude:: nvim_mouse/mouse_c
   :caption: 设置neovim只在命令行模式下使用鼠标

临时禁用鼠标
================

要暂时禁用鼠标支持，只需要在使用鼠标时按住 ``Shift`` 键

参考
==============

- `Neovim 101 — Mouse and Menu <https://alpha2phi.medium.com/neovim-101-mouse-and-menu-a2d2be60b3e1>`_
