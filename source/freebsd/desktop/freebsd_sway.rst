.. _freebsd_sway:

==================
FreeBSD Sway桌面
==================

:ref:`sway` 是基于 :ref:`wayland` 的轻量级图形管理器(和全功能的 :ref:`xfce` 不同)

准备工作
==========

在安装 :ref:`sway` 之前，首先需要为FreeBSD安装显卡驱动，这个安装是根据显卡硬件来决定的:

- 我的 :ref:`mbp15_late_2013` 使用NVIDIA显卡，所以安装 :ref:`freebsd_nvidia-driver` 。
- 如果是其他显卡芯片，例如我的 :ref:`thinkpad_x220` 使用Intel显卡，则需要 ``drm-kmod`` (这个软件包其实是不同显卡驱动和firmware的集成包，比较庞大) ，然后加载Intel i915驱动:

.. literalinclude:: freebsd_sway/intel_gpu
   :caption: Intel显卡内核模块加载

.. note::

   当执行了 ``kldload i915kms`` 命令加载了Intel显卡的内核驱动以后，会看到屏幕分辨率立即变高。如果没有变化则通常是驱动不匹配(主机非intel显卡)

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

需要配置一些环境变量以便用户能够运行sway，例如 ``XDG`` 运行目录。通常显示管理器会处理这些环境变量， :strike:`但是从控制台终端启动时需要自己处理` 我在FreeBSD 15上实践验证，可以备用配置 ``XDG_RUNTIME_DIR`` 花镜变量，默认进入就提供了设置好的环境变量(建议验证一下 ``env | grep XDG`` 输出) ::

   export XDG_RUNTIME_DIR=/tmp/`id -u`-runtime-dir
   test -d "$XDG_RUNTIME_DIR" || \
   { mkdir "$XDG_RUNTIME_DIR" ; chmod 700 "$XDG_RUNTIME_DIR" ;  }

注意，如果使用 ``sh`` 作为SHELL，则编辑 ``~/.shrc`` 添加::

   export XDG_RUNTIME_DIR=/tmp/`id -u`-runtime-dir

如果使用 ``tcsh`` 作为SHELL，则编辑 ``~/.cshrc`` 添加::

   setenv XDG_RUNTIME_DIR /tmp/`id -u`-runtime-dir

.. note::

   我在 FreeBSD 15 上实践已经不需要自己手工配置 ``XDG_RUNTIME_DIR`` 环境变量，默认设置了 ``XDG_RUNTIME_DIR=/var/run/xdg/$USER``

.. note::

   有用户报告在ZFS上使用Wayland客户端问题，原因是runtime目录需要访问 ``posix_fallocate()`` ，虽然作者没有重新问题，但是如果遇到类似问题，建议将运行目录改为 ``tmpfs`` ::

      mount -t tmpfs tmpfs /var/run

安装Sway实用工具
=================

- 为了能够更好实用sway，安装一些和i3兼容的程序::

   # pkg install alacritty dmenu dmenu-wayland
   pkg install sway swayidle swaylock-effects dmenu-wayland dmenu foot

- 需要安装字体(前面精简安装 ``sway`` 可能默认没有字体软件包，这会导致状态栏显示方框)，这里安装简体中文字体和核心字体::

   # 安装基础中文字体(Noto Sans CJK)
   pkg install noto-sc noto-basic

另外，我发现如果系统没有字体(我遇到精简安装sway没有安装上述字体)，不仅状态栏文字显示为方框，而且也无法启动 :ref:`foot` 这样的终端程序(例如按快捷键 ``$mod+Return`` )。此时我误以为快捷键无效(甚至修改配置调整 ``$mod`` )，实际上是字体没有安装导致无法运行程序而已。

启动sway
==========

- 启动sway之前，需要将自己的id加入到 ``video`` 用户组(这个组可以访问 ``/var/run/seatd.sock`` )::

   pw groupmod video -m huatai

- 启动::

   sway

出现报错:

.. literalinclude:: freebsd_sway/sway_error
   :caption: 启动sway报错，没有找到GPU

**终于找到原因了** 说来也简单，但是折腾了我好久。我在两次尝试FreeBSD sway失败后，考虑到自己主要是做后端开发运维，在桌面花费太多时间了，所以改为部署 :ref:`freebsd_xfce4` 。因为XFce4对 :ref:`wayland` 还是试验性支持，FreeBSD更是演进缓慢，所以实际上XFce4是传统的 :ref:`x_window` ，也就是通过 Xorg 运行。我猛然发现，原来在安装了 :ref:`freebsd_nvidia` 之后，Xorg居然也不能启动。还好Xorg有一个详细的启动日志检查 ``/var/log/Xorg.0.log`` 会看到如下错误:

.. literalinclude:: freebsd_nvidia-driver/version_error
   :caption: 我的笔记本显卡太老不能使用最新的550版本驱动

太乌龙了，原来解决的方法就是简单回滚安装旧版本 ``nvidia-driver`` :

.. literalinclude:: freebsd_nvidia-driver/rollback_nvidia
   :caption: 回滚 ``nvidia-driver`` 到 ``470.161.03`` 版本以适配 ``GeForce GT 750M Mac Edition``

看了一下 `FreeBSD Handbook: 5.10 Wayland on FreeBSD <https://docs.freebsd.org/en/books/handbook/x11/#x-wayland>`_ 提到有3种Wayland Compositor:

- Wayfire
- Hikari
- Sway

其中 `hikari - A Wayland Compositor <https://hikari.acmelabs.space>`_ 声明是在FreeBSD上开发，但也支持Linux。并且有人提到使用非常顺畅，后续我也将尝试 :ref:`freebsd_hikari`

参考
=====

- `Wayland on FreeBSD <https://euroquis.nl/freebsd/2021/03/16/wayland.html>`_
- `FreeBSD Handbook: 5.10 Wayland on FreeBSD <https://docs.freebsd.org/en/books/handbook/x11/#x-wayland>`_
