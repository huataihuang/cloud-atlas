.. _sway_apps:

================
Sway应用程序
================

由于sway是原生 :ref:`wayland` 窗口管理器，并且是轻量级系统，所以为了能够充分发挥性能，需要精心选择 **小而美** 的 ``Wayland Native Apps`` 应用程序。

视频播放
============

- mpv

- `clapper <https://rafostar.github.io/clapper/>`_ GNOME media player，使用GJS with GTK4 toolkit构建，后端采用 GStreamers with OpenGL 渲染

可以使用 :ref:`gentoo_flatpak` 安装:

.. literalinclude:: sway_apps/flatpak_clapper
   :caption: 使用 flatpak 安装和运行 clapper

参考
=======

- `What apps are you running on Sway? (Wayland Native Apps of course) <https://www.reddit.com/r/swaywm/comments/t8k07z/what_apps_are_you_running_on_sway_wayland_native/>`_
