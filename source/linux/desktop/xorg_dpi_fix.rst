.. _xorg_dpi_fix:

====================
修正xorg显示dpi
====================

最近一次 :ref:`arch_linux` 升级带来一个奇怪的问题: 进入 :ref:`lxqt` 桌面之后，字体显示非常巨大。不过，在chromium浏览器中，则字体显示如常。

看起来像是需要调整显示dpi，之前有一些经验，可以通过桌面配置，例如LXQt提供的 ``Appearance Configuration`` 中，提供 ``Font`` 配置面板，其中提供 ``Resolution (DPI)`` 配置(默认设置是96)。但是，显然有什么bug，xorg默认启动没有自动设只好dpi(现在通常不需要手工配置 ``xorg.conf`` )。

既然自动侦测不生效，那么还是老老实实手工配置吧:

- NVIDIA驱动软件包提供了一个生成标准xorg配置的工具::

   sudo nvidia-xconfig

执行后自动生成 ``/etc/X11/xorg.conf``

不过，此时重启进入X，发现字体还是很大。

- 在 ``xorg.conf`` 配置的 Screen 段落添加 ``DPI`` 配置如下:

.. literalinclude:: xorg_dpi_fix/xorg.conf
   :caption: /etc/X11/xorg.conf 添加DPI选项，强制指定DPI
   :emphasize-lines: 6

参考
========

- `arch linux: Xorg#Proprietary NVIDIA driver <https://wiki.archlinux.org/title/Xorg#Proprietary_NVIDIA_driver>`_
- `HOWTO set DPI in Xorg <https://linuxreviews.org/HOWTO_set_DPI_in_Xorg>`_
