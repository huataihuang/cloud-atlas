.. _wayland_vnc:

=================
Wayland环境VNC
=================

VNC服务器
===========

``wayvnc`` 是 ``wlroots-based`` Wayland compositors 的VNC server，通过附加到一个运行的Wayland会话，创建虚拟输入设备，以及通过RFB协议输出一个单一显示，来实现VNC。不过， ``wayvnc`` 不支持 Gnome 和 KDE 。好在我目前主要使用 :ref:`sway` ，所以使用 ``wayvnc`` 正好。

安装wayvnc
---------------

- 我在 :ref:`asahi_linux` 上使用 :ref:`sway` ，安装方法和 :ref:`arch_linux` 相同::

   pacman -S wayvnc

启动
--------

有2种方式启动wayvnc服务器:

无头模式(headless)
~~~~~~~~~~~~~~~~~~~~

- 无头模式(headless): 在终端启动:

.. literalinclude:: wayland_vnc/wayvnc_headless_server
   :caption: 无头模式(headless)启动sway的VNC服务器

这里我遇到一个报错::

   KMS: DRM_IOCTL_MODE_CREATE_DUMB failed: Permission denied
   00:00:04.558 [wlr] [render/allocator/gbm.c:114] gbm_bo_create failed
   00:00:04.558 [wlr] [render/swapchain.c:109] Failed to allocate buffer

在sway内部启动wayvnc
~~~~~~~~~~~~~~~~~~~~~~

- 在 :ref:`sway` 内部启动wayvnc:

.. literalinclude:: wayland_vnc/wayvnc_inside_sway
   :caption: 在sway内部启动wayvnc

VNC客户端
==========

Wayland的VNC客户端可以采用 `wlvncc <https://github.com/any1/wlvncc>`_ 。WayVNC 0.5支持使用OpenH268 RFB协议扩展的H.264编码。

- 编译依赖::

   GCC/clang
   meson
   ninja
   pkg-config
   wayland-protocols

- 编译和运行::

   git clone https://github.com/any1/aml.git
   git clone https://github.com/any1/wlvncc.git

   mkdir wlvncc/subprojects
   cd wlvncc/subprojects
   ln -s ../../aml .
   cd ..  #在wlvncc目录

   meson build
   ninja -C build

   ./build/wlvncc <address>

.. note::

   使用体验: 能够访问和连接 :ref:`macos` 共享的桌面，但是中文输入法切换存在问题，即使我避开了Win键，看起来能够输入中文，但是用空格键确认会卡住。后续我再尝试一下RDP方式访问桌面程序看看能否解决。

.. note::

   `waypipe <https://gitlab.freedesktop.org/mstoeckl/waypipe>`_ 实现了类似 ``ssh -X`` 的远程服务Wayland应用本地显示功能，有机会要实践一下，应该非常有用。

参考
=======

- `GitHub: wayvnc <https://github.com/any1/wayvnc>`_
- `Wayvnc server <https://n.ethz.ch/~dbernhard/wayvnc-server.html>`_
- `WayVNC 0.5 VNC Server For wlroots-Based Wayland Compositors Released <https://www.phoronix.com/news/WayVNC-0.5-Released>`_
