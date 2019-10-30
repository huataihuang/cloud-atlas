.. _rdesktop_mouse_cursor_appear:

==============================
rdesktop远程桌面鼠标图标显示
==============================

rdesktop鼠标图标消失
========================

默认情况下， ``rdesktop`` 远程访问Windows桌面，会把鼠标光标显示的白色光标改成Linux桌面的黑色实心光标，这样才能在远程桌面显示中看清。

不过，这个实现原理是rdesktop根据RDP对鼠标调用的图标替换实现的，所以如果更改了Windows桌面的显示比例(例如为了能够看清高分屏我调整 ``Custom scaling`` 设置为 ``150``)就会导致鼠标光标无法看到。

- 启动菜单 ``Settings => Personalization => Themes`` ，在这个风格设置中，有一个 ``Mouse cursor`` 选项可以调整鼠标指针样式。将样式调整成 ``Windows Black (system scheme)`` 这样 ``可能`` 可以解决rdesktop远程桌面无法正常显示鼠标光标的问题。

解决思路
==========

.. note::

   参考 `How to fix mouse cursor disappearing on Remote Desktop <https://camerondwyer.com/2018/05/09/how-to-fix-mouse-cursor-disappearing-on-on-remote-desktop/>`_ 不过，这个方法我实践没有成功。


``rdesktop`` 远程桌面显示的鼠标图形几乎无法看清，上述调整鼠标指针式样依然无法解决。

在 `Arch Linux社区文档 - Supplying missing cursors <https://wiki.archlinux.org/index.php/Cursor_themes#Supplying_missing_cursors>`_ 提供的解决方案：由于rdesktop使用从远程主机获得的光标，则由于协议限制难以看清。需要使用相同(或其他)光标风格来替代。为了能够替换，需要获得图像的 ``hash`` ，这是通过 ``XCURSOR_DISCOVER`` 环境变量激活，然后查看应用程序使用的光标::

   export XCURSOR_DISCOVER=1
   rdesktop ...

首次加载光标就会显示详细信息，例如::

   Cursor image name: 24020000002800000528000084810000
   ...
   Cursor image name: 7bf1cc07d310bf080118007e08fc30ff
   ...
   Cursor hash 24020000002800000528000084810000 returns 0x0

然后将这些hash软链接到目标图像，例如使用 ``Vanilla-DMZ`` 光标风格的 ``left_ptr`` 图像::

   ln -s /usr/share/icons/Vanilla-DMZ/cursors/left_ptr ~/.icons/default/cursors/24020000002800000528000084810000

Windows scale 150实践
======================

由于我使用的是MacBook Pro笔记本，Retina屏幕需要调整Windows桌面 Custom scaling 设置比率: ``150``

.. note::

   但是，不知道为何，之前调整桌面缩放比例之后，rdesktop远程访问也同步会调整比率。但是最近一次却发现调整桌面比率之后，rdesktop远程访问显示还是100%的比率，导致我无法对比。


FreeRDP
==========

现在我改为采用 `FreeRDP <http://www.freerdp.com/>`_ ，是通过 Rimmina 的内建freerdp功能来访问Windows远程桌面。也就是需要同时安装remmina和freerdp，这样remmina就能够直接访问RDP远程桌面。



参考
=======

- `How to fix mouse cursor disappearing on Remote Desktop <https://camerondwyer.com/2018/05/09/how-to-fix-mouse-cursor-disappearing-on-on-remote-desktop/>`_
- `Arch Linux社区文档 - Supplying missing cursors <https://wiki.archlinux.org/index.php/Cursor_themes#Supplying_missing_cursors>`_
