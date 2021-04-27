.. _tmux:

====================
tmux多会话终端管理
====================

tmux意思是 ``terminal multiplexer`` (终端多路器) ，它的功能是在一个单一屏幕(screen)内提供创建、访问和控制多个终端(或窗口)。tmux是作为 ``服务器-客户机`` 系统运行的，也就是在需要时创建一个服务器来管理所有会话，每个会话关联了一系列窗口，而tmux服务器就管理者所有的客户端、窗口和面板。

这意味着你可以运行一个进程，从系统断开，然后在之后从不同主机远程登陆到系统重新连接到正在工作的进程：通常是SSH运行在远程系统，启动 ``tmux`` ，在tmux会话中工作。任何时候都可以断开网络连接，随时可以重新连接tmux会话并恢复之前工作环境。

.. note::

   另一个常用的终端多路器是 ``screen`` ，在Red Hat Enterprise Linux 7及之前版本包含了 ``screen`` ，但是从 RHEL 8/CentOS 8开始， ``tmux`` 取代了 ``screen`` ，原因是screen代码台陈旧，Red Hat已经不再维护screen软件包，并且 ``tmux`` 代码代码更好并且支持新功能。 - `The 'screen' package is deprecated and not included in RHEL8.0.0. <https://access.redhat.com/solutions/4136481>`_

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

会话
------

- 检查系统存在的会话::

   tmux ls

显示举例::

   0: 3 windows (created Thu Apr 22 08:20:10 2021) (attached)

- 连接到最近创建的会话( ``a`` 表示 ``attach`` )::

   tmux a

.. note::

   和 ``screen`` 不同，即使之前有会话连接着，你的新attach依然能够连接会话

- 如果系统有多个会话，则使用参数 ``-t`` 来指定连接到哪个会话::

   tmux a -t 1

- 你可以创建多个会话，每个会话使用参数 ``-s`` 来指定会话名字::

   tmux new -s "database upgrade"

   tmux new -s "coding"

- 然后可以连接到指定的 ``database upgrade`` 会话::

   tmux attach -t "database upgrade"

- 屏幕滚动方法和 ``screen`` 类似，使用 ``ctrl+b`` ，然后按 ``[`` 进入滚动模式。之后就可以使用方向键， ``Page Up`` 或 ``Page Down`` 进行屏幕滚动

窗口
--------

在 ``tmux`` 会话中可以创建多个窗口(并且窗口还可以分割)，这样多个窗口就提供了多个工作桌面。

- 使用 ``ctrl-b`` 然后 ``w`` 可以列出当前会话(sesion)中所有的窗口(window)



分割窗口(pane)
---------------

- 按下 ``ctrl-b`` 加上 ``"`` 就把窗口分为上下两部分 (垂直分割)

- 按下 ``ctrl-b`` 加上 ``%`` 就是把窗口分为左右两部分 (horizontally, 水平分割)

- 调整pane大小的方法:

  - ``ctrl-b`` 然后 ``alt-方向键`` 按照方向调整pane大小
  - 如果在安装 ``alt`` 键时候快速按方向键，则可以连续调整

- 终端切换：在单个终端会话中，我们现在有3个终端，通过按下 ``ctrl-b`` 加上 ``方向键`` 我们可以切换不同终端

- 断开会话使用 ``ctrl-b`` 加上 ``d``

杀掉会话
--------------

- 使用 ``kill-session`` 可以杀掉指定会话::

   tmux kill-session -t "database upgrade"

帮助
--------

结合 ``ctrl-b`` 和 ``?`` 可以查看帮助

参考
=======

- `Excellent Utilities: tmux – terminal multiplexer software <https://www.linuxlinks.com/excellent-utilities-tmux-terminal-multiplexer-software/>`_
- `Tips for using tmux <https://www.redhat.com/sysadmin/tips-using-tmux>`_
- `In tmux can I resize a pane to an absolute value <https://stackoverflow.com/questions/16145078/in-tmux-can-i-resize-a-pane-to-an-absolute-value>`_
- `Adjusting screen split pane sizes in tmux <https://superuser.com/questions/863295/adjusting-screen-split-pane-sizes-in-tmux>`_
