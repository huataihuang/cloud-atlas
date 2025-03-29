.. _scim:

================
scim中文输入法
================

- 基础安装::

   sudo apt install scim scim-sunpinyin

也可以安装 ``scim-pinyin`` ，不过历史上 ``sunpinyin`` 基于统计调整输入，可能更好一些

- 配置: 在 ``~/.xinitrc`` 中添加以下配置::

   export XMODIFIERS=@im=SCIM
   export GTK_IM_MODULE="scim"
   export QT_IM_MODULE="scim"
   scim -d
   exec dwm

.. note::

   注意，这里我使用的窗口管理器是 :ref:`dwm`

xdm问题
==========

.. note::

   这个问题可能是特例，待解决

- 重新登陆一次X Window系统，然后通过 ``ctrl+space`` 就可以呼出 ``scim`` 输入法。不过，我发现此时只显示2种键盘 ``English/Keyboard`` 和 ``English/European`` ，怎么能够把安装的 ``sunpinyin`` 添加上去呢？

``scim-setup`` 无法启动，我发现将鼠标聚焦到输入位置，然后按下 ``[ctrl]+[space]`` ，如果该图形程序支持中文输入，则会自动出现 ``sunpinyin`` ，然后可以通过 ``[shift]`` 按键切换。

不过，存在问题是输入几个中文以后，无法继续
