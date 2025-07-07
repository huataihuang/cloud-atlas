.. _freebsd_hikari:

===================
FreeBSD hikari桌面
===================

由于部署 :ref:`freebsd_sway` 不顺利，改为尝试 `hikari - A Wayland Compositor <https://hikari.acmelabs.space>`_

hikari compositor 使用了几个以生产力为中心的概念，如 工作表、工作区等。这样就类似于平铺窗口管理器:

- 使用单个工作区或虚拟桌面进行用户交互
- 工作区由多个视图组成，这些视图是合成器中的工作窗口，分为工作表或组
- 工作表和组都由一组视图组成
- 最后是组合在一起的窗口

安装hikari
============

- 执行以下命令安装:

.. literalinclude:: freebsd_hikari/install
   :caption: 安装 hikari

- 简单配置:

.. literalinclude:: freebsd_hikari/config
   :caption: 配置hikari

- 修改 ``hikari.conf`` ::

   actions {
     terminal = "/usr/local/bin/alacritty"
     browser = "/usr/local/bin/chrome"
   }

使用hikari
==============

配置中有关于组合键映射配置，例如::

   bindings {
     keyboard {
     ...
       "L+Return" = action-terminal
       "L+b" = action-browser
     ...
     }
   }

这里 ``L`` 表示 ``L/super/Windows`` 键，也即是 ``Mod-4`` 键，可以按下 ``Windows`` 键加回车启动终端。操作非常类似 :ref:`sway`

- 启动::

   hikari -c /home/huatai/.config/hikari/hikari.conf

报错和 :ref:`freebsd_sway` 完全一样。这说明关键点是需要解决 wayland 如何使用 :ref:`freebsd_nvidia-driver`

参考
======

- `FreeBSD Handbook: 5.10 Wayland on FreeBSD <https://docs.freebsd.org/en/books/handbook/x11/#x-wayland>`_
