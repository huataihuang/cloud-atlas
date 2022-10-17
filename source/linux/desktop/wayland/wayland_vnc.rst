.. _wayland_vnc:

=================
Wayland环境VNC
=================

VNC服务器
===========

``wayvnc`` 是 ``wlroots-based`` Wayland compositors 的VNC server，通过附加到一个运行的Wayland会话，创建虚拟输入设备，以及通过RFB协议输出一个单一显示，来实现VNC。不过， ``wayvnc`` 不支持 Gnome 和 KDE 。好在我目前主要使用 :ref:`sway` ，所以使用 ``wayvnc`` 正好。

实践
-----

我在 :ref:`asahi_linux` 上使用 :ref:`sway` ，安装方法和 :ref:`arch_linux` 相同::

   pacman -S wayvnc

VNC客户端
==========

Wayland的VNC客户端可以采用 `wlvncc <https://github.com/any1/wlvncc>`_ 。WayVNC 0.5支持使用OpenH268 RFB协议扩展的H.264编码。

.. note::

   `waypipe <https://gitlab.freedesktop.org/mstoeckl/waypipe>`_ 实现了类似 ``ssh -X`` 的远程服务Wayland应用本地显示功能，有机会要实践一下，应该非常有用。

参考
=======

- `GitHub: wayvnc <https://github.com/any1/wayvnc>`_
- `WayVNC 0.5 VNC Server For wlroots-Based Wayland Compositors Released <https://www.phoronix.com/news/WayVNC-0.5-Released>`_
