.. _tuning_freebsd_for_mbp:

==========================
为MacBook Pro调优FreeBSD
==========================

修正键盘映射(keymap)
=======================

我使用NVIDIA的驱动提供的自动生成Xorg.conf配置(也可以使用 ``xorg -configure`` 配置)，但是默认的家盘布局实际上和MacBook键盘有差异，例如无法输入反引号和波浪号(同一个按键，在TAB键上方，数字键1左方)。

原因是 ``/usr/local/share/X11/xkb/symbols/us`` 配置中 ``TLDE`` 和 ``LSGT`` 映射对于MAC键盘恰好是反的，需要对换，具体步骤方法如下:

- 修改 ``/usr/local/share/X11/xkb/symbols/us`` 的 ``xkb_symbols "mac"`` 段落，将 ``TLDE`` 和 ``LSGT`` 内容对换，也就是将::

   xkb_symbols "mac" {
   
       include "us(basic)"
       name[Group1]= "English (Macintosh)";
       key.type[group1]="FOUR_LEVEL";
   
       // Slightly improvised from http://homepage.mac.com/thgewecke/kblayout.jpg
       key <LSGT> { [   section,  plusminus,       section,        plusminus ] };
       key <TLDE> { [     grave, asciitilde,    dead_grave,        dead_horn ] };
       key <AE01> { [         1,     exclam,    exclamdown,            U2044 ] };

修改成::

   xkb_symbols "mac" {
   
       include "us(basic)"
       name[Group1]= "English (Macintosh)";
       key.type[group1]="FOUR_LEVEL";
   
       // Slightly improvised from http://homepage.mac.com/thgewecke/kblayout.jpg
       key <TLDE> { [   section,  plusminus,       section,        plusminus ] };
       key <LSGT> { [     grave, asciitilde,    dead_grave,        dead_horn ] };
       key <AE01> { [         1,     exclam,    exclamdown,            U2044 ] };

- 然后在图形桌面的终端模拟器中执行::

   setxkbmap -layout us -variant mac

这样后续在图形界面中就能够正确输入反引号和波浪号。

.. note::

   我现在很矬，还没有搞定 xsession 自动执行 ``setxkbmap`` 。不过，我暂时将这条 ``setxkbmap`` 命令放在 ``.shrc`` 中，因为我的工作原因，每次登陆桌面必然会打开终端模拟程序，所以一定会执行到 ``.shrc`` 中指令。

   后续有空再优化吧...

自动化
-------------

.. note::

   以下是我尝试自动完成上述执行命令 ``setxkbmap -layout us -variant mac`` 但目前还没有成功，待探索

- (尚未实践成功)参考 `archliux: xprofile <https://wiki.archlinux.org/title/Xprofile>`_

``startx`` 以及任何Display manager都是用 ``~/.xinitrc`` 或 ``~/.xsession`` ，所以可以在这两个文件中添加::

   exec setxkbmap -layout us -variant mac

或者直接编辑 ``~/.xprofile`` 中添加::

   setxkbmap -layout us -variant mac &

- (尚未实践)对于终端字符(非图形界面)，则使用 ``kbdmap`` 命令，具体设置方法可以参考 `How to change keyboard mapping in the console? <https://forums.freebsd.org/threads/how-to-change-keyboard-mapping-in-the-console.50104/>`_ (原文是设置西班牙语键盘，应该可参考，不过我没有实践)

- (尚未实践成功)原文还介绍使xorg默认就按照上述映射，修订 ``/etc/X11/xorg.conf`` 配置添加::

   Section "InputClass"
           Identifier "libinput keyboard catchall"
           MatchIsKeyboard "on"
           MatchDevicePath "/dev/input/event*"
           Driver "libinput"
           Option "XkbRules" "evdev"
           Option "XkbLayout" "us"
           Option "XkbVariant" "mac"
   EndSection

参考
=======

- `Tuning Freebsd for Apple Hardware <https://blog.hplogsdon.com/tuning-freebsd-for-apple-hardware/>`_
- `Apple MacBook support on FreeBSD <https://wiki.freebsd.org/AppleMacbook>`_
- `Bug 252235 - x11/xorg: MacBook Pro 8,3 faulty key mapping <https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=252235>`_ 提到了和我一样的症状，实际解决方法需要结合多人建议，见上文我的实践
