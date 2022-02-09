.. _dwm:

=======================
dwm - 动态窗口管理器
=======================

``dwm`` 是为X Window系统开发得一个极简主义动态窗口管理器，深刻影响了 ``xmonad`` 和 ``awesome`` 等窗口管理器。 ``dwm`` 非常类似 ``vmii`` ，但是其内部更为简单。使用纯c语言开发，性能和安全性由于其极简的结构得到保障，并且特别的是， ``dwm`` 不提供任何配置接口，所有调整需要编辑源代码，然后重新编译。

``dwm`` 开源项目的指南解释了这个开源软件计划永远不超过2000行SLOC(Source lines of code)，并且用户配置选项全部包含在一个单一头文件中。

如 :ref:`intro_suckless` 所述， ``suckless`` 系列软件可以构建一个极简的 ``平铺`` 窗口管理桌面。例如以下案例

.. figure:: ../../../_static/linux/desktop/suckless/twm_luke_smith.gif

dmenu
===========

dmenu 是一个键盘驱动的菜单应用工具，作为 ``dwm`` 项目的一部分，通过一个用户配置的快捷键组合， ``dmenu`` 在屏幕边缘的顶部的标准输入流显示水平菜单。通常从用户 ``$PATH`` 显示一系列可用执行命令。用户可以输入一个程序名字，然后 ``dmeu`` 就根据列表显示相应的子字符串匹配用户输入。一旦选择， ``dmenu`` 就发送选中的文本给 ``stdout`` ，也就是pipe给shell来启动程序。

默认只支持 X Font Server字体，但是也有patch可以激活使用Xft的TrueType字体。

``dmenu`` 类似 GNOME Do 或 Katapult 这样的应用程序加载器，或者是Mac OS X的Quicksilver或LaunchBar，可以通过键盘快速启动图形界面的应用程序。

不仅 ``dwm`` 使用 ``dmenu`` ，其他窗口管理器，如 ``xmonad`` 或 ``Openbox`` 以及 ``uzbl`` web浏览器都是用 ``dmenu`` 。

安装
========

``suckless`` 系列软件安装需要从源代码编译

- 下载源代码::

   mkdir ~/suckless
   cd ~/suckless
   git clone https://git.suckless.org/dwm
   git clone https://git.suckless.org/st
   git clone https://git.suckless.org/dmenu

- 安装需要的依赖::

   sudo apt install libx11-dev libxft-dev libxinerama-dev

.. note::

   ``suckless`` 使用 ``config.mk`` 中的 ``Xinerama`` 库可以实现自动配置屏幕输出(例如显示器，投影仪等)，并且设置分辨率并准确绘制输出区域。

- 编译::

   cd ~/suckless/st
   sudo make clean install

   cd ~/suckless/dmenu
   sudo make clean install

   cd ~/suckless/dwm
   sudo make clean install

- 安装 ``xinit`` ::

   sudo apt install xinit

- 配置 ``~/.xinitrc`` ::

   exec dwm

- 然后执行::

   startx

此时会看到一个完全精简的黑白屏幕，干净漂亮

.. note::

   结合 :ref:`xpra` 服用更为舒适:

   - 自身可以提供远程应用桌面访问
   - 也可以访问其他计算和图形能力更强大的服务器

参考
======

- `dwm tutorial <https://dwm.suckless.org/tutorial/>`_
- `Dave's Visual Guide to dwm <https://ratfactor.com/dwm>`_
- `luk707/rpi_dwm.md <https://gist.github.com/luk707/46ef70635a36bcf434fabd7c6c302ce7>`_
- `Arch Linux 下安装 dwm (平铺式窗口管理器) <https://blog.csdn.net/weixin_44335269/article/details/117886927>`_
