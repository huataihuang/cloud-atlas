.. _sway_apps:

================
Sway应用程序
================

由于sway是原生 :ref:`wayland` 窗口管理器，并且是轻量级系统，所以为了能够充分发挥性能，需要精心选择 **小而美** 的 ``Wayland Native Apps`` 应用程序。

视频播放
============

- :ref:`mpv`

- `clapper <https://rafostar.github.io/clapper/>`_ GNOME media player，使用GJS with GTK4 toolkit构建，后端采用 GStreamers with OpenGL 渲染

可以使用 :ref:`gentoo_flatpak` 安装:

.. literalinclude:: sway_apps/flatpak_clapper
   :caption: 使用 flatpak 安装和运行 clapper

文件管理器
============

目前文件管理器大多与发行版桌面紧密结合，所以通常安装都会需要很多依赖。如无必要，在 :ref:`sway` 环境可以不用安装文件管理器。

我在 :ref:`gentoo_linux` 中使用 :ref:`sway` ，没有默认的文件管理器。按照 `Fedora Sway Spin项目 <https://fedoraproject.org/spins/sway/>`_ 推荐的文件管理器就是 :ref:`thunar`

另外也可以参考 `Fedora Cinnamon Spin项目 <https://fedoraproject.org/spins/cinnamon/>`_ (从GNOME 2 fork出来的轻量级发行版)，使用 ``nemo`` 作为文件管理器(但是安装也需要很多依赖)

参考
=======

- `What apps are you running on Sway? (Wayland Native Apps of course) <https://www.reddit.com/r/swaywm/comments/t8k07z/what_apps_are_you_running_on_sway_wayland_native/>`_
