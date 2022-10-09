.. _freebsd_sway:

==================
FreeBSD Sway桌面
==================

:ref:`sway` 是基于 :ref:`wayland` 的轻量级图形管理器(和全功能的 :ref:`xfce` 不同)

准备工作
==========

在安装 :ref:`sway` 之前，首先需要为FreeBSD安装显卡驱动，这个安装是根据显卡硬件来决定的，例如我的 :ref:`mbp15_late_2013` 使用NVIDIA显卡，所以安装 :ref:`freebsd_nvidia-driver` 。

如果是其他显卡芯片，例如Intel显卡，则需要 ``drm-kmod`` ，然后加载Intel i915驱动::

   pkg install drm-fbsd13-kmod
   kldload i915ksm

Sway安装
=========

执行以下命令安装sway包::

   sudo pkg install sway seatd
   sudo service seatd onestart

   sudo sysrc seatd_enable=YES

.. note::

   seated是一个负责管理服务的daemon，对于运行sway必须，否则启动报错

Sway配置
==========

最小化Sway配置 ``~/.config/sway/config`` ::

   input * xkb_rules evdev

不过，实际我采用 :ref:`run_sway` 方法，从系统安装包复制默认配置到用户目录::

   mkdir -p ~/.config/sway
   cp /usr/local/etc/sway/config ~/.config/sway/

修改 ``~/.config/sway/config`` ::

   # Logo key. Use Mod1 for Alt.
   input * xkb_rules evdev
   set $mod Mod4
   # Your preferred terminal emulator
   set $term alacritty
   set $lock swaylock -f -c 000000
   output "My Workstation" mode 1366x786@60Hz position 1366 0
   output * bg ~/wallpapers/mywallpaper.png stretch
   ### Idle configuration
   exec swayidle -w \
             timeout 300 'swaylock -f -c 000000' \
             timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
             before-sleep 'swaylock -f -c 000000'

需要配置一些环境变量以便用户能够运行sway，例如 ``XDG`` 运行目录。通常显示管理器会处理这些环境变量，但是从控制台终端启动时需要自己处理::

   export XDG_RUNTIME_DIR=/tmp/`id -u`-runtime-dir
   test -d "$XDG_RUNTIME_DIR" || \
   { mkdir "$XDG_RUNTIME_DIR" ; chmod 700 "$XDG_RUNTIME_DIR" ;  }

注意，如果使用 ``sh`` 作为SHELL，则编辑 ``~/.shrc`` 添加::

   export XDG_RUNTIME_DIR=/var/run/user/`id -u`

如果使用 ``tcsh`` 作为SHELL，则编辑 ``~/.cshrc`` 添加::

   setenv XDG_RUNTIME_DIR /var/run/user/`id -u`

.. note::

   有用户报告在ZFS上使用Wayland客户端问题，原因是runtime目录需要访问 ``posix_fallocate()`` ，虽然作者没有重新问题，但是如果遇到类似问题，建议将运行目录改为 ``tmpfs`` ::

      mount -t tmpfs tmpfs /var/run

安装Sway实用工具
=================

- 为了能够更好实用sway，安装一些和i3兼容的程序::

   # pkg install alacritty dmenu dmenu-wayland
   pkg install sway swayidle swaylock-effects alacritty dmenu-wayland dmenu

启动sway
==========

- 启动sway之前，需要将自己的id加入到 ``video`` 用户组(这个组可以访问 ``/var/run/seatd.sock`` )::

   pw groupmod video -m huatai

- 启动::

   sway

可能出现报错::

   ...
   00:00:10.109 [wlr] [backend/backend.c:217] Found 0 GPUs, cannot create backed
   00:00:10.109 [wlr] [backend/backend.c:386] Failed to open any DRM device
   00:00:10.109 [sway/server.c:56] Unable to create backend
   ...

太难了，我尝试参考 `NVIDIA (495) on sway tutorial + questions (Arch-based distros) <https://forums.developer.nvidia.com/t/nvidia-495-on-sway-tutorial-questions-arch-based-distros/192212>`_ 做了各种尝试，例如配置::

   export XDG_RUNTIME_DIR=/var/run/user/`id -u`


   #export LIBVA_DRIVER_NAME=nvidia
   #export MOZ_ENABLE_WAYLAND=1
   #export GDK_BACKEND=wayland
   #export QT_QPA_PLATFORM=wayland-egl
   #export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

   export CLUTTER_BACKEND=wayland
   export SDL_VIDEODRIVER=wayland
   export XDG_SESSION_TYPE=wayland
   export QT_QPA_PLATFORM=wayland
   export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
   export MOZ_ENABLE_WAYLAND=1
   export GBM_BACKEND=nvidia-drm
   export __GLX_VENDOR_LIBRARY_NAME=nvidia
   export WLR_NO_HARDWARE_CURSORS=1

但都没有解决这个问题

看了一下 `FreeBSD Handbook: 5.10 Wayland on FreeBSD <https://docs.freebsd.org/en/books/handbook/x11/#x-wayland>`_ 提到有3种Wayland Compositor:

- Wayfire
- Hikari
- Sway

其中 `hikari - A Wayland Compositor <https://hikari.acmelabs.space>`_ 声明是在FreeBSD上开发，但也支持Linux。并且有人提到使用非常顺畅，所以我改为尝试 :ref:`freebsd_hikari`

参考
=====

- `Wayland on FreeBSD <https://euroquis.nl/freebsd/2021/03/16/wayland.html>`_
- `FreeBSD Handbook: 5.10 Wayland on FreeBSD <https://docs.freebsd.org/en/books/handbook/x11/#x-wayland>`_
