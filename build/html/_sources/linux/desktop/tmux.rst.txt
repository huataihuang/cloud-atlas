.. _tmux:

====================
tmux多会话终端管理
====================

tmux意思是 ``terminal multiplexer`` (终端多路器) ，它的功能是在一个单一屏幕(screen)内提供创建、访问和控制多个终端(或窗口)。tmux是作为 ``服务器-客户机`` 系统运行的，也就是在需要时创建一个服务器来管理所有会话，每个会话关联了一系列窗口，而tmux服务器就管理者所有的客户端、窗口和面板。

.. note::

   另一个常用的终端多路器是 ``screen`` 

安装tmux
============

- debian/ubuntu::

   sudo apt install tmux

- arch linux::

   sudo pacman -Sy tmux

- 源代码安装::

   git clone https://https://github.com/tmux/
   cd tmux
   sh autogen.sh
   ./configure && make -j4
   sudo make install

- 在macOS平台著名的终端应用 iTerm2 就集成了tmux

使用tmux
==========

tmux给桌面，特别是远程桌面提供了非常好的连续工作机制。可以随时断开一个会话，当重新连接到同一个会话，所有的工作环境都恢复如初，就好像一直运行的样子，特别适合远程服务器维护。

首次启动tmux，会看到屏幕下方有一个绿色的条带，提供了使用信息，例如会话编号，谁在激活pane，tmux服务器的主机名以及日期时间。

tmux的 ``前导键`` 是 ``ctrl-b`` ，也就是按下 ``ctrl-b`` 就进入发送命令模式。

分割窗口
-----------

- 按下 ``ctrl-b`` 加上 ``"`` 就把窗口分为上下两部分 (垂直分割)

- 按下 ``ctrl-b`` 加上 ``%`` 就是把窗口分为左右两部分 (horizontally, 水平分割)

- 终端切换：在单个终端会话中，我们现在有3个终端，通过按下 ``ctrl-b`` 加上 ``方向键`` 我们可以切换不同终端

- 断开会话使用 ``ctrl-b`` 加上 ``d``

参考
=======

- `Excellent Utilities: tmux – terminal multiplexer software <https://www.linuxlinks.com/excellent-utilities-tmux-terminal-multiplexer-software/>`_
