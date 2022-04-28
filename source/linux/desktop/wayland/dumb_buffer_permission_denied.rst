.. _dumb_buffer_permission_denied:

==================================================
"failed to export dumb buffer: Permission denied"
==================================================

我在 :ref:`wayland` 的 :ref:`sway` 图形管理桌面中运行一些GTK应用，始终会出现报错::

   failed to export dumb buffer: Permission denied
   Failed to create scanout resource
   failed to export dumb buffer: Permission denied
   Failed to create scanout resource

   ** (midori:13469): WARNING **: 19:51:04.254: GDK is not able to create a GL context, falling back to glReadPixels (slow!): Unable to create a GL context
   failed to export dumb buffer: Permission denied
   Failed to create scanout resource
   failed to export dumb buffer: Permission denied
   Failed to create scanout resource

以上是 ``midori`` 浏览器的报错信息，无法浏览网络。

参考 `GNOME Applications under Wayland <https://wiki.gnome.org/Initiatives/Wayland/Applications>`_ 尝试添加环境变量::

   GDK_BACKEND=wayland midori

但是报错依旧...从midori的界面看，不断出现 ``Oops``

上述报错看起来是无法访问内核 framebuffer device 导致的

按照 `arch linxu: Midori#Wayand <https://wiki.archlinux.org/title/Midori#Wayland>`_ 说明：在使用 :ref:`wayland` 的窗口管理器运行Midori时如果想激活客户端装饰(client side decorations)，则使用 ``GTK_CSD=1``

我尝试了一下 ``qutebrowser`` ，报错信息也是一样的::

   failed to export dumb buffer: Permission denied
   Failed to create scanout resource
   20:19:32 INFO: Run :adblock-update to get adblock lists.
   failed to export dumb buffer: Permission denied
   Failed to create scanout resource
   ...
   zsh: segmentation fault  qutebrowser

但是参考 `voidlinux handbook: Wayland <https://docs.voidlinux.org/config/graphical-session/wayland.html>`_ 基于 GTK+ 和 Qt5 的浏览器，例如Midori和qutebrowser应该是原生就可以运行在Wayland的。

参考 `No HDMI output on Raspberry Pi 4 #453 <https://github.com/agherzan/meta-raspberrypi/issues/453>`_ 和 `RaspberryPi 4 DRM not working with YoE #461 <https://github.com/agherzan/meta-raspberrypi/issues/461>`_ 树莓派图形加速需要启用KMS，启动配置需要从::

   dtoverlay=vc4-fkms-v3d

修改成::

   dtoverlay=vc4-kms-v3d



参考
=======

- `GNOME Applications under Wayland <https://wiki.gnome.org/Initiatives/Wayland/Applications>`_
