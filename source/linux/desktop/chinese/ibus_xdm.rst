.. _ibus_xdm:

========================
xdm环境使用ibus中文输入
========================

tile窗口管理器设置ibus
========================

- 登陆系统在终端执行::

   ibus engine

提示信息::

   No engine is set.

- 查看引擎列表::

   ibus list-engine

选择对应引擎::

   ibus engine libpinyin

.. note::

   `i3-wm gaps can't switch ibus method <https://www.reddit.com/r/i3wm/comments/jct4ti/i3wm_gaps_cant_switch_ibus_method/>`_ 提供了一个简单的切换脚本

但是，发现在终端中启动了 ``leafpad`` ，尝试切换一次中文，然后输入却没有中文，看终端显示报错::

   Process Key Event failed: GDBus.Error.org.gtk.GDBus.UnmappedGError.Quark._g_2dio_2derror_2dquark.Code18: The connection is closed.

我感觉错误应该和 dbus 相关，之前 scim 不能输入中文应该也是这个原因

.. note::

   我目前暂时没有实践解决这个问题，不过或许可以尝试 `Getting Ibus working with tiling window manager <https://unix.stackexchange.com/questions/277692/getting-ibus-working-with-tiling-window-manager>`_ 的建议方法

参考
======

- `Getting Ibus working with tiling window manager <https://unix.stackexchange.com/questions/277692/getting-ibus-working-with-tiling-window-manager>`_
