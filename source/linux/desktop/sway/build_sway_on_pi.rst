.. _build_sway_on_pi:

====================
树莓派编译安装sway
====================

我在 :ref:`pi_400` 上尝试构建轻量级的桌面系统 :ref:`sway` 。由于Raspberry Pi OS没有提供直接执行的软件包，所以从源代码安装编译。从源代码编译 ``sway`` 需要安装2个组件:

- wlroots: 基础协议软件，也是很多平铺窗口管理器使用wayland所依赖的组件
- sway: 窗口管理器

编译wlroots
==============

依赖
-----

- 安装基础工具::

   sudo apt install build-essential
   sudo apt install git
   sudo apt install python3-pip

Meson
~~~~~~~

wlroots需要使用最新的meson::

   pip install --user meson

注意提示::

   Installing collected packages: meson
     The script meson is installed in '/home/huatai/.local/bin' which is not on PATH.
     Consider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location.

所以需要修改 ``~/.bashrc`` 添加以下配置::

   export PATH=$HOME/.local/bin:$PATH

然后执行刷新::

   source ~/.bashrc

- 直接安装wlroots依赖软件包::

   sudo apt install wayland-protocols \
   libwayland-dev \
   libegl1-mesa-dev \
   libgles2-mesa-dev \
   libdrm-dev \
   libgbm-dev \
   libinput-dev \
   libxkbcommon-dev \
   libgudev-1.0-dev \
   libpixman-1-dev \
   libsystemd-dev \
   cmake \
   libpng-dev \
   libavutil-dev \
   libavcodec-dev \
   libavformat-dev \
   ninja-build \
   meson

- 以下安装的软件包是可选的，用于支持X11，如果你使用完全wayland安装则不需要。我为了能兼容X11，也安装了以下软件包::

   sudo apt install libxcb-composite0-dev \
        libxcb-icccm4-dev \
        libxcb-image0-dev \
        libxcb-render0-dev \
        libxcb-xfixes0-dev \
        libxkbcommon-dev \
        libxcb-xinput-dev \
        libx11-xcb-dev  

编译和安装
=============

- clone软件代码仓库::

   mkdir ~/sway-build
   cd ~/sway-build
   git clone https://github.com/swaywm/wlroots.git
   cd wlroots
   git checkout 0.12.0

- 编译::

   meson build

这里在 :ref:`pi_400` 上会出现wayland版本过低报错::

   Found pkg-config: /usr/bin/pkg-config (0.29)
   Dependency wayland-server found: NO found 1.16.0 but need: '>=1.18'
   Found CMake: /usr/bin/cmake (3.16.3)
   Run-time dependency wayland-server found: NO (tried cmake)

   meson.build:99:0: ERROR: Invalid version of dependency, need 'wayland-server' ['>=1.18'] found '1.16.0'.

- 为解决sway的wayland版本要求， 在 :ref:`build_wayland_on_pi`


- 首先卸载刚才安装的系统提供的wayland::

   sudo apt remove wayland-protocols libwayland-dev
   sudo apt autoremove

.. note::

   这里不能全部卸载所有 wayland 组件，会导致其他常用的大量应用软件卸载

wayland官方文档提供了 `Building Weston <https://wayland.freedesktop.org/building.html>`_ 文档，不过比较方便是使用 `Wayland Build Tools <https://github.com/wayland-project/wayland-build-tools>`_ ，可以自动完成标准的Wayland编译和安装，并且可以自动下载和编译很多所需的上游组件:

- clone出 ``wayland-build-tools`` ::

   apt-get install -y git
   git clone git://anongit.freedesktop.org/wayland/wayland-build-tools

参考
======

- `Sway on Ubuntu - Simple Install <https://llandy3d.github.io/sway-on-ubuntu/simple_install/>`_
