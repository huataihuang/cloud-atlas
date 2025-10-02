.. _tmux:

====================
tmux多会话终端管理
====================

tmux意思是 ``terminal multiplexer`` (终端多路器) ，它的功能是在一个单一屏幕(screen)内提供创建、访问和控制多个终端(或窗口)。tmux是作为 ``服务器-客户机`` 系统运行的，也就是在需要时创建一个服务器来管理所有会话，每个会话关联了一系列窗口，而tmux服务器就管理着所有的客户端、窗口和面板。

这意味着你可以运行一个进程，从系统断开，然后在之后从不同主机远程登陆到系统重新连接到正在工作的进程：通常是SSH运行在远程系统，启动 ``tmux`` ，在tmux会话中工作。任何时候都可以断开网络连接，随时可以重新连接tmux会话并恢复之前工作环境。

.. note::

   另一个常用的终端多路器是 ``screen`` ，在Red Hat Enterprise Linux 7及之前版本包含了 ``screen`` ，但是从 RHEL 8/CentOS 8开始， ``tmux`` 取代了 ``screen`` ，原因是screen代码台陈旧，Red Hat已经不再维护screen软件包，并且 ``tmux`` 代码代码更好并且支持新功能。 - `The 'screen' package is deprecated and not included in RHEL8.0.0. <https://access.redhat.com/solutions/4136481>`_

安装tmux
============

- :ref:`ubuntu_linux` :

.. literalinclude:: tmux/ubuntu_tmux
   :caption: debian/ubuntu安装tmux

- :ref:`arch_linux` :

.. literalinclude:: tmux/arch_tmux
   :caption: arch安装tmux

- :ref:`gentoo_linux` :

.. literalinclude:: tmux/gentoo_tmux
   :caption: gentoo安装tmux

- 源代码安装:

.. literalinclude:: tmux/build_tmux
   :caption: 源代码编译安装tmux

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

- 可以重新命名会话(以下案例将会话0重命名成works)::

   tmux rename-session -t 0 works

可以用快捷键重命名当前会话: ``ctrl-b`` 加上 ``$``

- 如果系统有多个会话，则使用参数 ``-t`` 来指定连接到哪个会话::

   tmux a -t works

- 断开当前会话快捷键 ``ctrl-b`` 加上 ``d``

- 列出当前会话所有窗口 ``ctrl-b`` 加上 ``s``

- 你可以创建多个会话，每个会话使用参数 ``-s`` 来指定会话名字::

   tmux new -s "database upgrade"

   tmux new -s "coding"

.. note::

   一定要使用小写的 ``-s`` 参数创建新会话名字，如果使用大写 ``-S`` 或者忘记 ``new`` 命令(直接使用 ``tmux -s "coding"`` )则会导致后续找不到这个会话 ``tmux ls`` 显示不出来也无法重新连接，非常蒙圈。

- 然后可以连接到指定的 ``database upgrade`` 会话::

   tmux attach -t "database upgrade"

- 屏幕滚动方法和 ``screen`` 类似，使用 ``ctrl+b`` ，然后按 ``[`` 进入滚动模式。之后就可以使用方向键， ``Page Up`` 或 ``Page Down`` 进行屏幕滚动

窗口
--------

在 ``tmux`` 会话中可以创建多个窗口(并且窗口还可以分割)，这样多个窗口就提供了多个工作桌面。

- 使用 ``ctrl-b`` 然后 ``w`` 可以列出当前会话(sesion)中所有的窗口(window)
- 使用 ``ctrl-b`` 然后 ``,`` 可以重命名当前窗口名字

分割窗口(pane)
---------------

- 按下 ``ctrl-b`` 加上 ``"`` 就把窗口分为上下两部分 (垂直分割)

- 按下 ``ctrl-b`` 加上 ``%`` 就是把窗口分为左右两部分 (horizontally, 水平分割)

- 调整pane大小的方法:

  - ``ctrl-b`` 然后 ``alt-方向键`` 按照方向调整pane大小
  - 如果在按住 ``alt`` 键时候快速按方向键，则可以连续调整

- 终端切换：在单个终端会话中，我们现在有3个终端

  - 按下 ``ctrl-b`` 加上 ``方向键`` 我们可以切换不同终端
  - 按下 ``ctrl-b`` 加上  ``;`` 切换上一个窗格
  - 按下 ``ctrl-b`` 加上 ``o`` 切换下一个窗格
  - 按下 ``ctrl-b`` 加上 ``{`` 当前窗格与上一个窗格交换位置
  - 按下 ``ctrl-b`` 加上 ``}`` 当前窗格与下一个窗格交换位置
  - 按下 ``ctrl+b`` 加上 ``ctrl+o`` ：所有窗格向前移动一个位置，第一个窗格变成最后一个窗格。
  - 按下 ``ctrl+b`` 加上 ``alt+o`` ：所有窗格向后移动一个位置，最后一个窗格变成第一个窗格。
  - 按下 ``ctrl+b`` 加上 ``x`` ：关闭当前窗格。
  - 按下 ``ctrl+b`` 加上 ``!`` ：将当前窗格拆分为一个独立窗口。
  - 按下 ``ctrl+b`` 加上 ``z`` ：当前窗格全屏显示，再使用一次会变回原来大小。

- 断开会话使用 ``ctrl-b`` 加上 ``d``

杀掉会话
--------------

- 使用 ``kill-session`` 可以杀掉指定会话::

   tmux kill-session -t "database upgrade"

帮助
--------

结合 ``ctrl-b`` 和 ``?`` 可以查看帮助

tmux-config
================

色彩配置
---------

为了能够区分出远程和本地的tmux，可以在状态条上采用不同的色彩

修订 ``~/.tmux.conf`` 配置:

.. literalinclude:: tmux/tmux.conf
   :language: bash
   :caption: ~/.tmux.conf配置状态条配色
   :emphasize-lines: 2-4

此外，通过以下命令可以获取所有终端支持的色彩配置:

.. literalinclude:: tmux/color.sh
   :language: bash
   :caption: color.sh脚本获取终端支持的色彩

修改 ``{prefix}`` 键 ``ctrl+a``
----------------------------------

我的工作中不仅在远程服务器上使用 ``tmux`` ，也在本地使用 ``tmux`` ，而且会嵌套: 在本地的某个tmux窗口中访问远程服务器的 ``tmux`` ，所以我把本地 ``{prefix}`` 前导键修订成 ``ctrl+a``

.. literalinclude:: tmux/tmux.conf
   :language: bash
   :caption: ~/.tmux.conf配置 ``{prefix}`` 键 ``ctrl+a``
   :emphasize-lines: 7-10


案例
------

`samoshkin/tmux-config <https://github.com/samoshkin/tmux-config>`_ 提供了一个超级强大的tmux配置:

.. figure:: ../../_static/linux/desktop/tmux.gif
   :scale: 80

- 安装简便::

   git clone https://github.com/samoshkin/tmux-config.git
   ./tmux-config/install.sh

并且结合macOS上的iTerm2使用非常方便。

.. note::

   不过 `samoshkin/tmux-config <https://github.com/samoshkin/tmux-config>`_ 改动的默认配置实在太多，我感觉要重新熟悉不同的快捷键非常麻烦。我还是使用默认的tmux配置，尽量形成肌肉记忆。所以我实际还是放弃了 `samoshkin/tmux-config <https://github.com/samoshkin/tmux-config>`_

.. note::

   `samoshkin/tmux-config <https://github.com/samoshkin/tmux-config>`_ 在我的macOS(Intel架构macOS Sequoia 15.2)依然有 `.tmux.conf:41: syntax error and .tmux.conf:100: unknown key: if #38 <https://github.com/samoshkin/tmux-config/issues/38>`_ 错误，所以还是需要手工修订 ``~/.tmux.conf`` 

参考
=======

- `Comprehensive Tmux Tutorial for Beginners with a Cheat Sheet <https://protechnotes.com/comprehensive-tmux-tutorial-for-beginners-with-a-cheat-sheet/>`_ 这篇文档写得非常生动，对于学习可以参考该文档
- `tmux vs. screen <https://superuser.com/questions/236158/tmux-vs-screen>`_
- `Tmux vs. Screen tool comparison <https://linuxhint.com/tmux_vs_screen/>`_
- `How to Use tmux on Linux (and Why It’s Better Than Screen) <https://www.howtogeek.com/671422/how-to-use-tmux-on-linux-and-why-its-better-than-screen/>`_
- `Excellent Utilities: tmux – terminal multiplexer software <https://www.linuxlinks.com/excellent-utilities-tmux-terminal-multiplexer-software/>`_
- `Tips for using tmux <https://www.redhat.com/sysadmin/tips-using-tmux>`_
- `In tmux can I resize a pane to an absolute value <https://stackoverflow.com/questions/16145078/in-tmux-can-i-resize-a-pane-to-an-absolute-value>`_
- `Adjusting screen split pane sizes in tmux <https://superuser.com/questions/863295/adjusting-screen-split-pane-sizes-in-tmux>`_
- `Tmux 使用教程 <https://www.ruanyifeng.com/blog/2019/10/tmux.html>`_
- `tmux bottom status bar color change <https://unix.stackexchange.com/questions/60968/tmux-bottom-status-bar-color-change>`_
- `tmux简介（附修改前缀键ctrl+a的方法） <https://developer.aliyun.com/article/789729>`_
