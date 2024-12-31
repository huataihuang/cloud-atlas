.. _freebsd_wayland_sway:

=====================
FreeBSD Wayland+Sway
=====================

.. note::

   2024年底再次实践FreeBSD桌面，目标是在 :ref:`mbp15_late_2013` 构建 Wayland + Sway 桌面，并实现中文工作环境

:ref:`wayland` 是新的显示服务器，与 :ref:`x_window` 的主要区别如下

- Wayland只是一种协议: Wayland使用不同的机制充当客户端之间的中介，从而消除了对X服务器的依赖
- Xorg则包含了运行远程显示器的X11协议，X服务器接收连接并显示窗口；但是在Wayland中，则是由合成器(compositor)或窗口管理器(window manager)提供显示服务器，而不是传统的X服务器

由于Wayland不提供X服务器，并且期望compositor提供该支持，所以对于不支持Wayland的X11窗口管理器需要使用 ``-rootless`` 属性来启动 ``Xwayland``

检查显卡
========

- 执行以下命令查询自己主机使用的显卡:

.. literalinclude:: freebsd_wayland_sway/pciconf
   :caption: 检查显卡

我的 :ref:`mbp15_late_2013` 显示输出是NVIDIA:

.. literalinclude:: freebsd_wayland_sway/pciconf_output
   :caption: 检查显卡

.. warning::

   一定要安装支持显卡芯片的NVIDIA驱动，对于非常古老的NVIDIA显卡，例如我的 :ref:`mbp15_late_2013` 是不能使用最新550版本驱动，会导致运行 ``sway`` 报错:

   .. literalinclude:: freebsd_sway/sway_error
      :caption: 启动sway报错，没有找到GPU

   解决方法是安装指定版本 ``nvidia-driver`` ，例如 :ref:`freebsd_xfce4` 实践通过检查Xorg日志确认需要安装指定 ``470.xx`` 旧驱动



Tips
======

- 当前很多软件在Wayland可能有少量问题，并且完善支持的桌面较少
- 对于compositor，需要内核支持 ``evdev`` 驱动，该驱动已经在 ``GENERIC`` 内核build in，但是如果定制内核没有buind in ``evdev`` ，则必须通过内核模块加载 ``evdev``
- 使用Wayland的用户必须位于 ``video`` 用户组:

.. literalinclude:: freebsd_wayland_sway/group_add_video
   :caption: 将 ``admin`` 用户加入 ``video`` 组(举例)

- 所有的compositor都可以和 ``graphics/drm-kmod`` 开源驱动一起工作，但是 NVIDIA 图形卡可能在使用专有驱动时会存在问题

安装
======

- 安装 ``wayland`` 和 ``seated`` :

.. literalinclude:: freebsd_wayland_sway/install_wayland_seated
   :caption: 安装 ``wayland`` 和 ``seated``

安装比较简单，但是需要仔细看一下输出提示:

.. literalinclude:: freebsd_wayland_sway/install_wayland_seated_output
   :caption: 安装 ``wayland`` 和 ``seated`` 的输出信息

在安装了协议(wayland)和支持(seated)包以后，compositor负责创建用户界面。所有使用Wayland的compositor都需要在环境中定义一个运行时目录(从FreeBSD 14.1开始，该目录会自动创建和定义)，可以通过以下 :ref:`bash` 命令创建:

.. literalinclude:: freebsd_wayland_sway/bash_env
   :caption: 设置 ``XDG_RUNTIME_DIR`` 环境变量

注意，对于 ``csh`` ，可以在 ``~/.cshrc`` 添加:

.. literalinclude:: freebsd_wayland_sway/csh_env
   :caption: 设置 csh 的 ``XDG_RUNTIME_DIR`` 环境变量，配置文件 ``~/.cshrc``

.. warning::

   原文中提到 ZFS 肯能会导致一些Wayland客户端问题，原因时这些客户端访问 runtime 目录的 ``posix_fallocate()``

   建议时将 ``/var/run`` 目录调整到 ``tmpfs`` (参考 `FreeBSD tmpfs <https://man.freebsd.org/cgi/man.cgi?tmpfs>`_ )

   - 修订 ``/boot/loader.conf`` 添加配置

   .. literalinclude:: freebsd_wayland_sway/enable_tmpfs
      :caption: 激活tmpfs

   - 配置了 ``/etc/fstab`` :

   .. literalinclude:: freebsd_wayland_sway/fstab_tmpfs
      :caption: 配置 ``/etc/fstab`` 添加tmpfs挂载

   **上述配置我还没有实践** 因为目前还没有遇到wayland客户端问题

- 设置 ``seated`` 在系统启动时启动:

.. literalinclude:: freebsd_wayland_sway/seated_enable
   :caption: 激活 ``seated`` 在系统启动时启动

seatd 守护进程有助于管理合成器中非 root 用户对共享系统设备的访问，包括显卡

sway
============

- Sway compositor平铺合成器，安装可以通过以下命令完成:

.. literalinclude:: freebsd_wayland_sway/install_sway
   :caption: 安装sway

安装后的输出信息:

.. literalinclude:: freebsd_wayland_sway/install_sway_output
   :caption: 安装sway输出信息

- 基础配置:

.. literalinclude:: freebsd_wayland_sway/config_sway
   :caption: sway基础配置

- 修订 ``~/.config/sway`` 配置文件，添加一些重要配置:

.. literalinclude:: freebsd_wayland_sway/config
   :caption: sway配置修订
   :emphasize-lines: 2

参考
======

- `FreeBSD Handbook: Chapter 6. Wayland <https://docs.freebsd.org/en/books/handbook/wayland/>`_
- `Freebsd 14 Wayland and Wayfire using Nvidia on Dell XPS 15 <https://forums.freebsd.org/threads/freebsd-14-wayland-and-wayfire-using-nvidia-on-dell-xps-15.91283/>`_ 介绍了需要 ``nvidia-driver nvidia-settings nvidia-drm-515-kmod libva-intel-driver libva-utils`` 似乎是一个成功案例可以借鉴
