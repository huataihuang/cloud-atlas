.. _fbterm:

=================================
FbTerm - 支持UTF-8中文的字符终端
=================================

我在 :ref:`pi_400` 上使用 :ref:`raspberry_pi_os` ，由于硬件性能有限，并且想尝试古早的终端感觉(用最低的硬件实现最大的性能)，所以尝试在完全终端的环境下工作。这就需要实现基本的在终端下输入中文和显示中文能力。默认tty终端只能显示一个字节字符，不支持UTF-8，所以只能显示英文。

`FbTerm终端软件 <http://code.google.com/p/fbterm/>`_ 提供了采用系统 ``framebuffer`` 的终端模拟器，最关键的是，它支持UTF-8字符集，也就是能够实现CJK字符显示。这对在终端环境实现中文输入是男的的支持。假如你是系统轻量级极致追求者，甚至想获得古早Unix字符终端体验，你可以尝试使用这个软件，实现在字符终端(无X.org)平台上实现中文输入。

根据资料 :ref:`fcitx` 可以在FbTerm上使用。

安装
=======

- :ref:`raspberry_pi_os` 发行版内置 ``fbterm`` 软件包可直接安装::

   sudo apt install fbterm

启动framebuffer
=================

为了实现较好的字符终端体验，建议使用 framebuffer 设备

- 创建 ``/etc/udev/my-rules.d/framebuffer.rules`` ::

   KERNEL=="fb0",  OWNER="huatai", MODE="0640"

这样用户 ``huatai`` 就能够使用 ``fb0`` (framebuffer设备)

另一种方式是将 ``huatai`` 用户假如 ``video`` 组::

   sudo gpasswd -a huatai video

.. note::

   如果用户没有framebuffer设备权限，可能会提示错误::

      can't open buffer frame device!
      mmap /dev/zero: Operation not permitted
      Using VESA requires root privilege

- 设置允许使用系统快捷键资源::

   sudo setcap 'cap_sys_tty_config+ep' /usr/bin/fbterm

或者使用以下命令::

   sudo chmod u+s /usr/bin/fbterm

.. note::

   如果没有允许使用系统快捷键资源，启动 ``fbterm`` 会提示错误::

      [input] can't change kernel keymap table, all shortcuts will NOT work! 

- 默认启动时会自动生成 ``~/.fbtermrc`` ，通过修订该文件可以定制一些功能，例如字体大小和快捷键，我们需要修改输入法 ``input-method`` ::

   input-method=fcitx-fbterm

设置tty登陆后自动运行FbTerm
===============================

每次登陆 ``tty`` 要输入 ``fbterm`` 显然很麻烦，可以在环境变量中设置成自动执行:

- 修改 ``~/.bashrc`` 添加::

   if [ “$TERM” = “linux”  ] ; then
       fbterm
   fi

安装fcitx输入法
=================

最新的 ``fcitx5`` 没有提供 ``fbterm`` 支持，所以还是安装版本 ``fcitx-fbterm`` ::

   sudo apt install fcitx fcitx-fbterm

这里安装会自动依赖安装 ``fcitx-pinyin`` ``fcitx-table-wubi`` ``fcitx-googlepinyin`` 等

.. note::

   旧版本 ``fcitx`` 只需要 85MB 空间，比 ``fcitx5`` 动辄244MB安装空间要小很多

- 配置 ``~/.xinitrc`` 或 ``~/.bashrc`` 或者标准环境配置文件 ``/etc/environment`` 添加:

.. literalinclude:: fcitx/environment
   :language: bash
   :caption: fcitx环境变量

参考
=======

- `FbTerm: Better terminal windows when you don’t have X <https://www.linux.com/news/fbterm-better-terminal-windows-when-you-dont-have-x/>`_
- `樹莓派 (Raspberry Pi) tty 以 Fbterm 和 fcitx 輸入中文 <https://vocus.cc/article/5ff7b117fd8978000120a18f>`_
