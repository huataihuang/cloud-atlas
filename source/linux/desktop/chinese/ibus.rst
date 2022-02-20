.. _ibus:

============
ibus输入法
============

- 安装::

   sudo apt install ibus ibus-libpinyin

- 修改 ``.initrc`` ::

   export XMODIFIERS=@im=ibus
   export GTK_IM_MODULE=ibus
   export QT_IM_MODULE=ibus

   ibus-daemon -drx

   exec dwm

- 登陆系统后，可以使用 ``ibus-setup`` 进行设置

参考
======

- `Gentoo IBus <https://wiki.gentoo.org/wiki/IBus>`_
- `arch linux IBus <https://wiki.archlinux.org/title/IBus>`_
- `i3-wm gaps can't switch ibus method <https://www.reddit.com/r/i3wm/comments/jct4ti/i3wm_gaps_cant_switch_ibus_method/>`_
- `Getting Ibus working with tiling window manager <https://unix.stackexchange.com/questions/277692/getting-ibus-working-with-tiling-window-manager>`_
